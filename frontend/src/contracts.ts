import { getAddress, type Address } from 'viem'

export const addresses = {
  icft: import.meta.env.VITE_ICFT_ADDRESS as Address | undefined,
  lendingPool: import.meta.env.VITE_LENDING_POOL_ADDRESS as Address | undefined,
  riskEngine: import.meta.env.VITE_RISK_ENGINE_ADDRESS as Address | undefined,
  priceOracle: import.meta.env.VITE_PRICE_ORACLE_ADDRESS as Address | undefined,
  interestRateModel: import.meta.env.VITE_INTEREST_RATE_MODEL_ADDRESS as Address | undefined,
}

export const chainId = Number(import.meta.env.VITE_CHAIN_ID || 31337)
export const rpcUrl = import.meta.env.VITE_RPC_URL || 'http://127.0.0.1:8545'

export const erc20Abi = [
  { type: 'function', name: 'balanceOf', stateMutability: 'view', inputs: [{ name: 'account', type: 'address' }], outputs: [{ type: 'uint256' }] },
  { type: 'function', name: 'allowance', stateMutability: 'view', inputs: [{ name: 'owner', type: 'address' }, { name: 'spender', type: 'address' }], outputs: [{ type: 'uint256' }] },
  { type: 'function', name: 'approve', stateMutability: 'nonpayable', inputs: [{ name: 'spender', type: 'address' }, { name: 'amount', type: 'uint256' }], outputs: [{ type: 'bool' }] },
  { type: 'function', name: 'totalSupply', stateMutability: 'view', inputs: [], outputs: [{ type: 'uint256' }] },
  { type: 'function', name: 'name', stateMutability: 'view', inputs: [], outputs: [{ type: 'string' }] },
  { type: 'function', name: 'symbol', stateMutability: 'view', inputs: [], outputs: [{ type: 'string' }] },
] as const

export const lendingPoolAbi = [
  { type: 'function', name: 'depositCollateral', stateMutability: 'payable', inputs: [], outputs: [] },
  { type: 'function', name: 'withdrawCollateral', stateMutability: 'nonpayable', inputs: [{ name: 'amountETH', type: 'uint256' }], outputs: [] },
  { type: 'function', name: 'borrow', stateMutability: 'nonpayable', inputs: [{ name: 'amountICFT', type: 'uint256' }], outputs: [] },
  { type: 'function', name: 'repay', stateMutability: 'nonpayable', inputs: [{ name: 'amountICFT', type: 'uint256' }], outputs: [] },
  { type: 'function', name: 'getPosition', stateMutability: 'view', inputs: [{ name: 'user', type: 'address' }], outputs: [{ name: 'position', type: 'tuple', components: [
    { name: 'collateralETH', type: 'uint256' }, { name: 'principalDebtUSD', type: 'uint256' }, { name: 'accruedInterestUSD', type: 'uint256' }, { name: 'lastInterestUpdate', type: 'uint256' }, { name: 'active', type: 'bool' }
  ] }] },
  { type: 'function', name: 'getDebt', stateMutability: 'view', inputs: [{ name: 'user', type: 'address' }], outputs: [{ type: 'uint256' }] },
  { type: 'function', name: 'getLTV', stateMutability: 'view', inputs: [{ name: 'user', type: 'address' }], outputs: [{ type: 'uint256' }] },
  { type: 'function', name: 'getCollateralValueUSD', stateMutability: 'view', inputs: [{ name: 'user', type: 'address' }], outputs: [{ type: 'uint256' }] },
  { type: 'function', name: 'getCurrentInterest', stateMutability: 'view', inputs: [{ name: 'user', type: 'address' }], outputs: [{ type: 'uint256' }] },
  { type: 'function', name: 'getAvailableBorrow', stateMutability: 'view', inputs: [{ name: 'user', type: 'address' }], outputs: [{ type: 'uint256' }] },
  { type: 'function', name: 'getAvailableLiquidity', stateMutability: 'view', inputs: [], outputs: [{ type: 'uint256' }] },
  { type: 'function', name: 'getUtilization', stateMutability: 'view', inputs: [], outputs: [{ type: 'uint256' }] },
  { type: 'function', name: 'paused', stateMutability: 'view', inputs: [], outputs: [{ type: 'bool' }] },
  { type: 'function', name: 'icft', stateMutability: 'view', inputs: [], outputs: [{ type: 'address' }] },
] as const

export const riskEngineAbi = [
  { type: 'function', name: 'getMaxLTVBps', stateMutability: 'view', inputs: [], outputs: [{ type: 'uint256' }] },
  { type: 'function', name: 'getLiquidationThresholdBps', stateMutability: 'view', inputs: [], outputs: [{ type: 'uint256' }] },
  { type: 'function', name: 'getTargetLTVBps', stateMutability: 'view', inputs: [], outputs: [{ type: 'uint256' }] },
  { type: 'function', name: 'getLiquidationBonusBps', stateMutability: 'view', inputs: [], outputs: [{ type: 'uint256' }] },
] as const

export const oracleAbi = [
  { type: 'function', name: 'getETHUSDPrice', stateMutability: 'view', inputs: [], outputs: [{ type: 'uint256' }] },
  { type: 'function', name: 'getICFTUSDPrice', stateMutability: 'view', inputs: [], outputs: [{ type: 'uint256' }] },
  { type: 'function', name: 'getICFTPriceSource', stateMutability: 'view', inputs: [], outputs: [{ type: 'uint8' }] },
] as const

export const rateModelAbi = [
  { type: 'function', name: 'getBorrowRateBps', stateMutability: 'view', inputs: [{ name: 'utilizationBps', type: 'uint256' }], outputs: [{ type: 'uint256' }] },
  { type: 'function', name: 'getMaxBorrowUtilizationBps', stateMutability: 'view', inputs: [], outputs: [{ type: 'uint256' }] },
] as const

export function normalizeAddress(value?: string): Address | undefined {
  if (!value) return undefined
  try { return getAddress(value) } catch { return undefined }
}
