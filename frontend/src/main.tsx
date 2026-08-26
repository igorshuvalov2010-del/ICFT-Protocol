import React, { useEffect, useMemo, useState } from 'react'
import { createRoot } from 'react-dom/client'
import {
  createPublicClient, createWalletClient, custom, formatUnits, http,
  parseEther, parseUnits, type Address, type Hash
} from 'viem'
import {
  addresses, chainId, erc20Abi, lendingPoolAbi, oracleAbi,
  rateModelAbi, riskEngineAbi, rpcUrl
} from './contracts'
import './styles.css'

declare global { interface Window { ethereum?: any } }

type Tab = 'overview' | 'markets' | 'docs'
type Action = 'deposit' | 'borrow' | 'repay' | 'withdraw' | null

type Position = {
  collateral: bigint; debt: bigint; interest: bigint; ltv: bigint
  collateralUsd: bigint; availableBorrow: bigint; icftBalance: bigint
  ethBalance: bigint; utilization: bigint; paused: boolean; ethPrice: bigint
  icftPrice: bigint; maxLtv: bigint; liquidationThreshold: bigint
  borrowRate: bigint; availableLiquidity: bigint
}

const chain = {
  id: chainId,
  name: chainId === 31337 ? 'Anvil' : `Chain ${chainId}`,
  nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
  rpcUrls: { default: { http: [rpcUrl] } }
}

const publicClient = createPublicClient({ chain, transport: http(rpcUrl) })

function requiredAddresses() {
  return Boolean(
    addresses.icft && addresses.lendingPool && addresses.riskEngine &&
    addresses.priceOracle && addresses.interestRateModel
  )
}
function fmt(value: bigint, decimals = 18, max = 4) {
  const raw = Number(formatUnits(value, decimals))
  if (!Number.isFinite(raw)) return '—'
  return raw.toLocaleString('en-US', { maximumFractionDigits: max })
}
function usd(value: bigint) { return `$${fmt(value, 18, 2)}` }
function short(addr: string) { return `${addr.slice(0, 6)}…${addr.slice(-4)}` }
function percent(bps: bigint) { return `${(Number(bps) / 100).toFixed(1)}%` }
function health(ltv: bigint, threshold: bigint) {
  if (ltv === 0n) return null
  return Number(threshold) / Number(ltv)
}

async function readPosition(account: Address): Promise<Position> {
  if (!requiredAddresses()) throw new Error('Contract addresses are not configured. Fill .env from your deployment output.')
  const [
    pos, debt, ltv, collateralUsd, interest, availableBorrow,
    icftBalance, ethBalance, utilization, paused, ethPrice, icftPrice,
    maxLtv, liquidationThreshold, availableLiquidity
  ] = await Promise.all([
    publicClient.readContract({ address: addresses.lendingPool!, abi: lendingPoolAbi, functionName: 'getPosition', args: [account] }),
    publicClient.readContract({ address: addresses.lendingPool!, abi: lendingPoolAbi, functionName: 'getDebt', args: [account] }),
    publicClient.readContract({ address: addresses.lendingPool!, abi: lendingPoolAbi, functionName: 'getLTV', args: [account] }),
    publicClient.readContract({ address: addresses.lendingPool!, abi: lendingPoolAbi, functionName: 'getCollateralValueUSD', args: [account] }),
    publicClient.readContract({ address: addresses.lendingPool!, abi: lendingPoolAbi, functionName: 'getCurrentInterest', args: [account] }),
    publicClient.readContract({ address: addresses.lendingPool!, abi: lendingPoolAbi, functionName: 'getAvailableBorrow', args: [account] }),
    publicClient.readContract({ address: addresses.icft!, abi: erc20Abi, functionName: 'balanceOf', args: [account] }),
    publicClient.getBalance({ address: account }),
    publicClient.readContract({ address: addresses.lendingPool!, abi: lendingPoolAbi, functionName: 'getUtilization' }),
    publicClient.readContract({ address: addresses.lendingPool!, abi: lendingPoolAbi, functionName: 'paused' }),
    publicClient.readContract({ address: addresses.priceOracle!, abi: oracleAbi, functionName: 'getETHUSDPrice' }),
    publicClient.readContract({ address: addresses.priceOracle!, abi: oracleAbi, functionName: 'getICFTUSDPrice' }),
    publicClient.readContract({ address: addresses.riskEngine!, abi: riskEngineAbi, functionName: 'getMaxLTVBps' }),
    publicClient.readContract({ address: addresses.riskEngine!, abi: riskEngineAbi, functionName: 'getLiquidationThresholdBps' }),
    publicClient.readContract({ address: addresses.lendingPool!, abi: lendingPoolAbi, functionName: 'getAvailableLiquidity' }),
  ])
  const rate = await publicClient.readContract({
    address: addresses.interestRateModel!, abi: rateModelAbi,
    functionName: 'getBorrowRateBps', args: [utilization as bigint]
  })
  const p = pos as any
  return {
    collateral: p.collateralETH, debt: debt as bigint, interest: interest as bigint,
    ltv: ltv as bigint, collateralUsd: collateralUsd as bigint,
    availableBorrow: availableBorrow as bigint, icftBalance: icftBalance as bigint,
    ethBalance: ethBalance as bigint, utilization: utilization as bigint,
    paused: paused as boolean, ethPrice: ethPrice as bigint,
    icftPrice: icftPrice as bigint, maxLtv: maxLtv as bigint,
    liquidationThreshold: liquidationThreshold as bigint,
    borrowRate: rate as bigint, availableLiquidity: availableLiquidity as bigint
  }
}

function App() {
  const [tab, setTab] = useState<Tab>('overview')
  const [account, setAccount] = useState<Address>()
  const [action, setAction] = useState<Action>(null)
  const [amount, setAmount] = useState('')
  const [position, setPosition] = useState<Position>()
  const [loading, setLoading] = useState(false)
  const [status, setStatus] = useState('')
  const [error, setError] = useState('')
  const [txHash, setTxHash] = useState<Hash>()

  const configured = requiredAddresses()

  const refresh = async () => {
    if (!account || !configured) return
    try { setPosition(await readPosition(account)); setError('') }
    catch (e: any) { setError(e?.shortMessage || e?.message || 'Unable to read protocol state') }
  }

  useEffect(() => { refresh() }, [account])

  useEffect(() => {
    const nodes = Array.from(document.querySelectorAll<HTMLElement>('.reveal'))
    if (!nodes.length) return
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible')
          observer.unobserve(entry.target)
        }
      })
    }, { threshold: 0.12, rootMargin: '0px 0px -50px' })
    nodes.forEach((node) => observer.observe(node))
    return () => observer.disconnect()
  }, [tab])
  useEffect(() => {
    if (!window.ethereum) return
    const onAccounts = (accounts: string[]) => setAccount(accounts[0] as Address | undefined)
    const onChain = () => window.location.reload()
    window.ethereum.on?.('accountsChanged', onAccounts)
    window.ethereum.on?.('chainChanged', onChain)
    return () => {
      window.ethereum.removeListener?.('accountsChanged', onAccounts)
      window.ethereum.removeListener?.('chainChanged', onChain)
    }
  }, [])

  const connect = async () => {
    setError('')
    if (!window.ethereum) {
      setError('No compatible wallet detected. Install MetaMask or another injected wallet.')
      return
    }
    try {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' }) as string[]
      const currentChain = parseInt(await window.ethereum.request({ method: 'eth_chainId' }), 16)
      if (currentChain !== chainId) {
        try {
          await window.ethereum.request({
            method: 'wallet_switchEthereumChain',
            params: [{ chainId: `0x${chainId.toString(16)}` }]
          })
        } catch {
          setError(`Switch your wallet to chain ${chainId} (local Anvil).`)
          return
        }
      }
      setAccount(accounts[0] as Address)
    } catch (e: any) { setError(e?.message || 'Wallet connection failed') }
  }

  const walletClient = useMemo(() =>
    account && window.ethereum
      ? createWalletClient({ account, chain, transport: custom(window.ethereum) })
      : undefined, [account])

  const execute = async () => {
    if (!account || !walletClient || !action || !amount) return
    setLoading(true); setError(''); setStatus('Preparing transaction…'); setTxHash(undefined)
    try {
      if (action === 'deposit') {
        const value = parseEther(amount)
        setStatus('Confirm deposit in your wallet…')
        const hash = await walletClient.writeContract({
          address: addresses.lendingPool!, abi: lendingPoolAbi,
          functionName: 'depositCollateral', value, account
        })
        setTxHash(hash); setStatus('Waiting for confirmation…')
        await publicClient.waitForTransactionReceipt({ hash })
      }
      if (action === 'borrow') {
        const value = parseUnits(amount, 18)
        setStatus('Confirm borrow in your wallet…')
        const hash = await walletClient.writeContract({
          address: addresses.lendingPool!, abi: lendingPoolAbi,
          functionName: 'borrow', args: [value], account
        })
        setTxHash(hash); setStatus('Waiting for confirmation…')
        await publicClient.waitForTransactionReceipt({ hash })
      }
      if (action === 'repay') {
        const value = parseUnits(amount, 18)
        const allowance = await publicClient.readContract({
          address: addresses.icft!, abi: erc20Abi,
          functionName: 'allowance', args: [account, addresses.lendingPool!]
        })
        if ((allowance as bigint) < value) {
          setStatus('Approve ICFT in your wallet…')
          const approval = await walletClient.writeContract({
            address: addresses.icft!, abi: erc20Abi,
            functionName: 'approve', args: [addresses.lendingPool!, value], account
          })
          setTxHash(approval); await publicClient.waitForTransactionReceipt({ hash: approval })
        }
        setStatus('Confirm repayment in your wallet…')
        const hash = await walletClient.writeContract({
          address: addresses.lendingPool!, abi: lendingPoolAbi,
          functionName: 'repay', args: [value], account
        })
        setTxHash(hash); setStatus('Waiting for confirmation…')
        await publicClient.waitForTransactionReceipt({ hash })
      }
      if (action === 'withdraw') {
        const value = parseEther(amount)
        setStatus('Confirm withdrawal in your wallet…')
        const hash = await walletClient.writeContract({
          address: addresses.lendingPool!, abi: lendingPoolAbi,
          functionName: 'withdrawCollateral', args: [value], account
        })
        setTxHash(hash); setStatus('Waiting for confirmation…')
        await publicClient.waitForTransactionReceipt({ hash })
      }
      setStatus('Transaction confirmed.')
      setAmount(''); await refresh()
      setTimeout(() => { setAction(null); setStatus('') }, 1300)
    } catch (e: any) {
      setError(e?.shortMessage || e?.details || e?.message || 'Transaction failed')
      setStatus('')
    } finally { setLoading(false) }
  }

  const h = position ? health(position.ltv, position.liquidationThreshold) : null
  const hasDebt = position ? position.debt > 0n : false
  const healthLabel = !hasDebt ? 'No debt' : h !== null && h >= 1.2 ? 'Healthy' : h !== null && h >= 1 ? 'At risk' : 'Liquidatable'
  const actionTitle =
    action === 'deposit' ? 'Deposit ETH' :
    action === 'borrow' ? 'Borrow ICFT' :
    action === 'repay' ? 'Repay ICFT' : 'Withdraw ETH'
  const maxValue =
    action === 'deposit' ? position?.ethBalance :
    action === 'borrow' ? position?.availableBorrow :
    action === 'repay' ? position?.icftBalance : position?.collateral
  const maxText = action === 'borrow'
    ? `${fmt(maxValue ?? 0n)} ICFT available`
    : `${fmt(maxValue ?? 0n)} ${action === 'repay' ? 'ICFT' : 'ETH'} available`

  const scrollTo = (id: string) =>
    document.getElementById(id)?.scrollIntoView({ behavior: 'smooth', block: 'start' })

  return <div className="site">
    <div className="bg-grid" />
    <div className="ambient ambient-one" />
    <div className="ambient ambient-two" />

    <header className="nav shell">
      <button className="brand" onClick={() => { setTab('overview'); window.scrollTo({ top: 0, behavior: 'smooth' }) }}>
        <span className="brand-symbol">I</span><strong>ICFT</strong><i />
      </button>
      <nav className="nav-links">
        <button className={tab === 'overview' ? 'active' : ''} onClick={() => setTab('overview')}>Protocol</button>
        <button className={tab === 'markets' ? 'active' : ''} onClick={() => setTab('markets')}>Markets</button>
        <button onClick={() => { setTab('overview'); scrollTo('dashboard') }}>Dashboard</button>
        <button className={tab === 'docs' ? 'active' : ''} onClick={() => setTab('docs')}>Docs</button>
      </nav>
      <button className="wallet" onClick={connect}>
        <span className="wallet-dot" />{account ? short(account) : 'Connect wallet'}
      </button>
    </header>

    {!configured && <div className="config-banner shell">
      <strong>Local setup:</strong> add the five contract addresses from your latest Foundry deployment to <code>.env</code>, then restart Vite.
    </div>}
    {error && <div className="toast error"><span>{error}</span><button onClick={() => setError('')}>×</button></div>}

    {tab === 'overview' && <>
      <main>
        <section className="hero shell reveal hero-reveal">
          <div className="hero-copy">
            <div className="eyebrow">DECENTRALIZED CREDIT INFRASTRUCTURE</div>
            <div className="hero-title">ICFT<span className="hero-dot">.</span></div>
            <div className="hero-name">Innovative Credit &amp; Finance Token</div>
            <h1>Capital, re-engineered<br /><span>for the on-chain economy.</span></h1>
            <p>Decentralized lending infrastructure built around ETH collateral and ICFT credit.</p>
            <div className="hero-actions">
              <button className="primary" onClick={() => scrollTo('dashboard')}>Explore protocol <span>↗</span></button>
              <button className="secondary" onClick={() => setTab('docs')}>View tokenomics</button>
            </div>
          </div>

          <div className="coin-stage">
            <div className="coin-shadow" />
            <div className="coin">
              <div className="coin-ring ring-one" />
              <div className="coin-ring ring-two" />
              <div className="coin-core">
                <span className="coin-i">I</span>
                <span className="coin-name">ICFT</span>
              </div>
            </div>
            <div className="coin-caption">
              <b>ICFT</b>
              <span>FIXED SUPPLY · ERC-20</span>
            </div>
          </div>
        </section>

        <section className="ticker reveal"><div>ETH COLLATERAL <span>•</span> ICFT CREDIT <span>•</span> RISK ENGINE <span>•</span> ORACLE VALUATION <span>•</span> ETH COLLATERAL <span>•</span> ICFT CREDIT</div></section>

        <section className="protocol shell reveal" id="protocol">
          <div className="section-head">
            <div className="eyebrow">01 · PROTOCOL</div>
            <h2>Liquidity without<br /><span>selling.</span></h2>
            <p>Use ETH as collateral, access ICFT credit, and keep exposure to the underlying asset.</p>
          </div>
          <div className="flow reveal-stagger">
            <Flow n="01" title="Deposit ETH" text="Lock ETH in the Lending Pool as collateral." />
            <Flow n="02" title="Borrow ICFT" text="Borrow within the protocol's LTV and liquidity limits." />
            <Flow n="03" title="Use liquidity" text="Use the borrowed ICFT as your credit asset." />
            <Flow n="04" title="Repay & withdraw" text="Repay ICFT and unlock your ETH collateral." />
          </div>
        </section>

        <section className="dashboard-section reveal" id="dashboard">
          <div className="shell">
            <div className="section-head compact">
              <div className="eyebrow">02 · LIVE POSITION</div>
              <h2>Your position.</h2>
              <p>Direct wallet-to-contract interaction on the current ICFT local MVP.</p>
            </div>
            <div className="dashboard-grid">
              <div className="position-panel">
                <div className="panel-top"><span>POSITION</span><span className={position?.paused ? 'status danger' : 'status'}>{position?.paused ? 'Protocol paused' : account ? 'Connected' : 'Wallet not connected'}</span></div>
                <div className="big-number">{position ? fmt(position.collateral) : '0.00'} <small>ETH</small></div>
                <div className="muted">Collateral</div>
                <div className="metric-grid">
                  <Metric label="Collateral value" value={position ? usd(position.collateralUsd) : '$0.00'} />
                  <Metric label="ICFT debt" value={position ? `${fmt(position.debt)} ICFT` : '0 ICFT'} />
                  <Metric label="Current LTV" value={position ? percent(position.ltv) : '0.0%'} />
                  <Metric label="Liquidation threshold" value={position ? percent(position.liquidationThreshold) : '—'} />
                </div>
                <div className="health-row"><div><span>Health factor</span><b>{h ? h.toFixed(2) : '—'}</b></div><div className={`health-pill ${healthLabel.toLowerCase().replace(' ', '-')}`}>{healthLabel}</div></div>
                <div className="health-track"><span style={{ width: `${Math.min(Number(position?.ltv || 0n) / Number(position?.liquidationThreshold || 1n) * 100, 100)}%` }} /></div>
                <div className="actions">
                  <button className="primary" onClick={() => { if (!account) connect(); else setAction('deposit') }}>Deposit ETH</button>
                  <button onClick={() => { if (!account) connect(); else setAction('borrow') }}>Borrow ICFT</button>
                  <button onClick={() => { if (!account) connect(); else setAction('repay') }}>Repay</button>
                  <button onClick={() => { if (!account) connect(); else setAction('withdraw') }}>Withdraw ETH</button>
                </div>
              </div>
              <aside className="side-panel">
                <div className="side-block"><span>ETH / USD</span><b>{position ? usd(position.ethPrice) : '—'}</b></div>
                <div className="side-block"><span>ICFT / USD</span><b>{position ? usd(position.icftPrice) : '—'}</b></div>
                <div className="side-block"><span>Borrow APR</span><b>{position ? percent(position.borrowRate) : '—'}</b><small>Utilization: {position ? percent(position.utilization) : '—'}</small></div>
                <div className="side-block"><span>Available ICFT liquidity</span><b>{position ? fmt(position.availableLiquidity) : '—'}</b></div>
                <button className="refresh" onClick={refresh} disabled={!account}>Refresh position ↻</button>
              </aside>
            </div>
          </div>
        </section>

        <section className="token-section shell reveal">
          <div className="section-head"><div className="eyebrow">03 · ICFT TOKEN</div><h2>Fixed supply.<br /><span>Programmable credit.</span></h2></div>
          <div className="token-grid reveal-stagger">
            <Token label="TOTAL SUPPLY" value="1,000,000,000" suffix="ICFT" />
            <Token label="INITIAL REFERENCE" value="$0.50" suffix="per ICFT" />
            <Token label="PRIMARY ROLE" value="Credit asset" suffix="ETH-backed borrowing" />
          </div>
        </section>

        <section className="markets-section reveal"><div className="shell">
          <div className="section-head"><div className="eyebrow">04 · LIQUIDITY</div><h2>From collateral<br /><span>to liquidity.</span></h2><p>The current MVP stops at the lending layer. Real market routing is intentionally a later phase.</p></div>
          <div className="market-grid reveal-stagger"><Market pair="ICFT / USDT" status="Planned" text="Liquidity market for converting ICFT credit into external stablecoin liquidity." /><Market pair="ICFT / ETH" status="Planned" text="Future market for deeper ecosystem liquidity and collateral-native routes." /></div>
        </div></section>

        <section className="security shell reveal">
          <div className="section-head"><div className="eyebrow">05 · RISK</div><h2>Risk comes<br /><span>first.</span></h2></div>
          <div className="risk-grid reveal-stagger"><Risk title="Oracle" text="ETH/USD and ICFT/USD prices feed normalized protocol accounting." /><Risk title="LTV" text="Borrow capacity is constrained by the RiskEngine and configured max LTV." /><Risk title="Liquidation" text="Unhealthy positions can be liquidated through the authorized MVP operator path." /><Risk title="Emergency pause" text="The pool exposes pause controls for critical user-side operations." /></div>
        </section>

        <section className="docs shell reveal"><div className="docs-card">
          <div><div className="eyebrow">06 · DOCUMENTATION</div><h2>Build with<br /><span>ICFT.</span></h2><p>The current repository is a localhost/Anvil MVP. Do not use it with real funds.</p></div>
          <div className="doc-links"><a href="https://github.com/igorshuvalov2010-del/ICFT-Protocol" target="_blank">GitHub ↗</a><a href="https://github.com/igorshuvalov2010-del/ICFT-Protocol/blob/main/CODE_README.md" target="_blank">Code guide ↗</a><a href="https://github.com/igorshuvalov2010-del/ICFT-Protocol/blob/main/docs/MVP_SPEC.md" target="_blank">MVP spec ↗</a></div>
        </div></section>
      </main>
    </>}

    {tab === 'markets' && <Page title="Markets" eyebrow="LIQUIDITY" text="Liquidity is a planned expansion layer of the current ICFT MVP."><div className="market-grid large"><Market pair="ICFT / USDT" status="Planned" text="Initial liquidity direction. No fake pool statistics are shown." /><Market pair="ICFT / ETH" status="Planned" text="Future market. The current LendingPool does not implement an AMM." /></div></Page>}
    {tab === 'docs' && <Page title="Documentation" eyebrow="PROTOCOL DOCUMENTATION" text="Current ICFT is an early localhost/Anvil MVP."><div className="docs-list"><a href="https://github.com/igorshuvalov2010-del/ICFT-Protocol" target="_blank"><b>GitHub repository</b><span>Source code and deployment scripts ↗</span></a><a href="https://github.com/igorshuvalov2010-del/ICFT-Protocol/blob/main/CODE_README.md" target="_blank"><b>CODE_README.md</b><span>Architecture and actual MVP behavior ↗</span></a><a href="https://github.com/igorshuvalov2010-del/ICFT-Protocol/blob/main/docs/MVP_SPEC.md" target="_blank"><b>MVP specification</b><span>Functional target for the lending MVP ↗</span></a></div></Page>}

    {action && <div className="modal-backdrop" onMouseDown={() => !loading && setAction(null)}>
      <div className="modal" onMouseDown={e => e.stopPropagation()}>
        <button className="close" onClick={() => !loading && setAction(null)}>×</button>
        <div className="eyebrow">ICFT · {action.toUpperCase()}</div><h3>{actionTitle}</h3><p>{maxText}</p>
        <div className="input-wrap"><input autoFocus value={amount} onChange={e => setAmount(e.target.value)} placeholder="0.00" inputMode="decimal" /><span>{action === 'borrow' || action === 'repay' ? 'ICFT' : 'ETH'}</span></div>
        <button className="primary wide" disabled={loading || !amount || position?.paused} onClick={execute}>{loading ? status || 'Processing…' : actionTitle}</button>
        {status && <div className="tx-status">{status}{txHash && <span> · {txHash.slice(0, 10)}…</span>}</div>}
        <div className="modal-note">Transactions are signed by your wallet. Never enter a private key.</div>
      </div>
    </div>}
  </div>
}

function Flow({ n, title, text }: { n: string; title: string; text: string }) { return <article className="flow-card"><span>{n}</span><h3>{title}</h3><p>{text}</p></article> }
function Metric({ label, value }: { label: string; value: string }) { return <div className="metric"><span>{label}</span><b>{value}</b></div> }
function Token({ label, value, suffix }: { label: string; value: string; suffix: string }) { return <div className="token"><span>{label}</span><b>{value}</b><small>{suffix}</small></div> }
function Market({ pair, status, text }: { pair: string; status: string; text: string }) { return <article className="market"><div><b>{pair}</b><span>{status}</span></div><p>{text}</p><div className="market-line" /></article> }
function Risk({ title, text }: { title: string; text: string }) { return <article><b>{title}</b><p>{text}</p></article> }
function Page({ title, eyebrow, text, children }: { title: string; eyebrow: string; text: string; children: React.ReactNode }) {
  return <main className="page shell"><div className="section-head"><div className="eyebrow">{eyebrow}</div><h2>{title}</h2><p>{text}</p></div>{children}</main>
}

createRoot(document.getElementById('root')!).render(<React.StrictMode><App /></React.StrictMode>)
