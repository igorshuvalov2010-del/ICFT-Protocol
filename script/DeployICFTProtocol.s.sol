// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {ICFT} from "../src/core/ICFT/token/ICFT.sol";
import {PriceOracle} from "../src/core/ICFT/oracle/PriceOracle.sol";
import {InterestRateModel} from "../src/core/ICFT/lending/InterestRateModel.sol";
import {LendingPool} from "../src/core/ICFT/lending/LendingPool.sol";
import {LiquidationEngine} from "../src/core/ICFT/lending/LiquidationEngine.sol";
import {RiskEngine} from "../src/core/ICFT/risk/RiskEngine.sol";
import {IInterestRateModel} from "../src/core/interfaces/IInterestRateModel.sol";

contract DeployICFTProtocol is Script {
    bytes32 internal constant ERC1967_ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    struct CollateralConfig {
        address asset;
        address usdFeed;
        uint8 assetDecimals;
        bool enabled;
        string label;
    }

    struct DeploymentConfig {
        address admin;
        address upgradeAdmin;
        address fundAHolder;
        address liquidityRecipient;
        address strategicReserveRecipient;
        address futureInvestorsRecipient;
        address founderRecipient;
        address developersRecipient;
        address ecosystemRecipient;
        address liquidationOperator;
        address ethUsdFeed;
        uint256 maxPriceAge;
        uint256 initialManualICFTPrice;
        uint8 initialManualICFTPriceDecimals;
        uint256 fundAAllocation;
        uint256 liquidityBuffer;
        uint256 maxLtvBps;
        uint256 liquidationThresholdBps;
        uint256 targetLtvBps;
        uint256 liquidationBonusBps;
        uint256 kink1Bps;
        uint256 kink2Bps;
        uint256 kink3Bps;
        uint256 rate1Bps;
        uint256 rate2Bps;
        uint256 rate3Bps;
        uint256 rate4Bps;
        uint256 maxBorrowUtilizationBps;
        CollateralConfig wbtcCollateral;
        CollateralConfig wstethCollateral;
    }

    struct DeploymentArtifacts {
        address icftImplementation;
        address oracleImplementation;
        address rateModelImplementation;
        address riskEngineImplementation;
        address lendingPoolImplementation;
        address liquidationEngineImplementation;
        address icftProxy;
        address oracleProxy;
        address rateModelProxy;
        address riskEngineProxy;
        address lendingPoolProxy;
        address liquidationEngineProxy;
        address icftProxyAdmin;
        address oracleProxyAdmin;
        address rateModelProxyAdmin;
        address riskEngineProxyAdmin;
        address lendingPoolProxyAdmin;
        address liquidationEngineProxyAdmin;
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        DeploymentConfig memory config = _loadConfig(deployer);
        DeploymentArtifacts memory artifacts;

        vm.startBroadcast(deployerPrivateKey);

        ICFT icftImplementation = new ICFT();
        PriceOracle oracleImplementation = new PriceOracle();
        InterestRateModel rateModelImplementation = new InterestRateModel();
        RiskEngine riskEngineImplementation = new RiskEngine();
        LendingPool lendingPoolImplementation = new LendingPool();
        LiquidationEngine liquidationEngineImplementation = new LiquidationEngine();

        artifacts.icftImplementation = address(icftImplementation);
        artifacts.oracleImplementation = address(oracleImplementation);
        artifacts.rateModelImplementation = address(rateModelImplementation);
        artifacts.riskEngineImplementation = address(riskEngineImplementation);
        artifacts.lendingPoolImplementation = address(lendingPoolImplementation);
        artifacts.liquidationEngineImplementation = address(liquidationEngineImplementation);
        artifacts.icftProxy = _deployIcftProxy(config, icftImplementation);
        artifacts.oracleProxy = _deployOracleProxy(config, oracleImplementation);

        IInterestRateModel.RateConfig memory rateConfig = IInterestRateModel.RateConfig({
            kink1Bps: config.kink1Bps,
            kink2Bps: config.kink2Bps,
            kink3Bps: config.kink3Bps,
            rate1Bps: config.rate1Bps,
            rate2Bps: config.rate2Bps,
            rate3Bps: config.rate3Bps,
            rate4Bps: config.rate4Bps,
            maxBorrowUtilizationBps: config.maxBorrowUtilizationBps
        });
        artifacts.rateModelProxy = _deployRateModelProxy(config, rateModelImplementation, rateConfig);
        artifacts.riskEngineProxy = _deployRiskEngineProxy(config, artifacts, riskEngineImplementation);
        artifacts.lendingPoolProxy = _deployLendingPoolProxy(config, artifacts, lendingPoolImplementation);
        artifacts.liquidationEngineProxy =
            _deployLiquidationEngineProxy(config, artifacts, liquidationEngineImplementation);

        artifacts.icftProxyAdmin = _readProxyAdmin(artifacts.icftProxy);
        artifacts.oracleProxyAdmin = _readProxyAdmin(artifacts.oracleProxy);
        artifacts.rateModelProxyAdmin = _readProxyAdmin(artifacts.rateModelProxy);
        artifacts.riskEngineProxyAdmin = _readProxyAdmin(artifacts.riskEngineProxy);
        artifacts.lendingPoolProxyAdmin = _readProxyAdmin(artifacts.lendingPoolProxy);
        artifacts.liquidationEngineProxyAdmin = _readProxyAdmin(artifacts.liquidationEngineProxy);

        ICFT icft = ICFT(artifacts.icftProxy);
        LendingPool lendingPool = LendingPool(payable(artifacts.lendingPoolProxy));
        LiquidationEngine liquidationEngine = LiquidationEngine(payable(artifacts.liquidationEngineProxy));

        if (config.admin == deployer) {
            lendingPool.grantRole(lendingPool.LIQUIDATION_BOT_ROLE(), address(liquidationEngine));
            liquidationEngine.grantRole(liquidationEngine.OPERATOR_ROLE(), config.liquidationOperator);
            _configureCollateral(lendingPool, PriceOracle(artifacts.oracleProxy), config.wbtcCollateral);
            _configureCollateral(lendingPool, PriceOracle(artifacts.oracleProxy), config.wstethCollateral);
        }

        vm.stopBroadcast();

        if (config.admin != deployer) {
            console2.log("WARNING: ADMIN_ADDRESS is not the deployer.");
            console2.log("Grant LIQUIDATION_BOT_ROLE to LiquidationEngine manually on LendingPool.");
            console2.log("Grant OPERATOR_ROLE to LIQUIDATION_OPERATOR manually on LiquidationEngine.");
            console2.log("Register enabled collateral assets manually in PriceOracle and LendingPool.");
        }

        if (config.fundAHolder == deployer) {
            vm.startBroadcast(deployerPrivateKey);
            icft.transfer(address(lendingPool), config.fundAAllocation);
            vm.stopBroadcast();
        } else {
            console2.log("WARNING: FUND_A_HOLDER is not the deployer.");
            console2.log("Transfer Fund A allocation manually to LendingPool:", address(lendingPool));
        }

        _printDeploymentSummary(config, artifacts);
    }

    function _loadConfig(address deployer) internal view returns (DeploymentConfig memory config) {
        config.admin = vm.envOr("ADMIN_ADDRESS", deployer);
        config.upgradeAdmin = vm.envOr("UPGRADE_ADMIN_ADDRESS", config.admin);
        config.fundAHolder = vm.envOr("FUND_A_HOLDER", deployer);
        config.liquidityRecipient = vm.envOr("LIQUIDITY_RECIPIENT", deployer);
        config.strategicReserveRecipient = vm.envOr("STRATEGIC_RESERVE_RECIPIENT", deployer);
        config.futureInvestorsRecipient = vm.envOr("FUTURE_INVESTORS_RECIPIENT", deployer);
        config.founderRecipient = vm.envOr("FOUNDER_RECIPIENT", deployer);
        config.developersRecipient = vm.envOr("DEVELOPERS_RECIPIENT", deployer);
        config.ecosystemRecipient = vm.envOr("ECOSYSTEM_RECIPIENT", deployer);
        config.liquidationOperator = vm.envOr("LIQUIDATION_OPERATOR", deployer);

        config.ethUsdFeed = vm.envAddress("ETH_USD_FEED");
        config.maxPriceAge = vm.envOr("MAX_PRICE_AGE", uint256(1 hours));
        config.initialManualICFTPrice = vm.envOr("INITIAL_MANUAL_ICFT_PRICE", uint256(1e8));
        config.initialManualICFTPriceDecimals = uint8(vm.envOr("INITIAL_MANUAL_ICFT_PRICE_DECIMALS", uint256(8)));

        config.fundAAllocation = vm.envOr("FUND_A_ALLOCATION", uint256(200_000_000 ether));
        config.liquidityBuffer = vm.envOr("LIQUIDITY_BUFFER", uint256(1_000 ether));

        config.maxLtvBps = vm.envOr("MAX_LTV_BPS", uint256(8_000));
        config.liquidationThresholdBps = vm.envOr("LIQUIDATION_THRESHOLD_BPS", uint256(9_000));
        config.targetLtvBps = vm.envOr("TARGET_LTV_BPS", uint256(8_500));
        config.liquidationBonusBps = vm.envOr("LIQUIDATION_BONUS_BPS", uint256(500));

        config.kink1Bps = vm.envOr("KINK1_BPS", uint256(5_000));
        config.kink2Bps = vm.envOr("KINK2_BPS", uint256(8_000));
        config.kink3Bps = vm.envOr("KINK3_BPS", uint256(9_000));
        config.rate1Bps = vm.envOr("RATE1_BPS", uint256(500));
        config.rate2Bps = vm.envOr("RATE2_BPS", uint256(800));
        config.rate3Bps = vm.envOr("RATE3_BPS", uint256(1_500));
        config.rate4Bps = vm.envOr("RATE4_BPS", uint256(2_000));
        config.maxBorrowUtilizationBps = vm.envOr("MAX_BORROW_UTILIZATION_BPS", uint256(9_000));

        config.wbtcCollateral = CollateralConfig({
            asset: vm.envOr("WBTC_COLLATERAL_ASSET", address(0)),
            usdFeed: vm.envOr("WBTC_USD_FEED", address(0)),
            assetDecimals: uint8(vm.envOr("WBTC_ASSET_DECIMALS", uint256(8))),
            enabled: vm.envOr("ENABLE_WBTC_COLLATERAL", false),
            label: "wBTC"
        });
        config.wstethCollateral = CollateralConfig({
            asset: vm.envOr("WSTETH_COLLATERAL_ASSET", address(0)),
            usdFeed: vm.envOr("WSTETH_USD_FEED", address(0)),
            assetDecimals: uint8(vm.envOr("WSTETH_ASSET_DECIMALS", uint256(18))),
            enabled: vm.envOr("ENABLE_WSTETH_COLLATERAL", false),
            label: "wstETH"
        });
    }

    function _printDeploymentSummary(DeploymentConfig memory config, DeploymentArtifacts memory artifacts) internal view {
        console2.log("=== ICFT Protocol Upgradeable Deployment Summary ===");
        console2.log("chainid", block.chainid);
        console2.log("protocol admin", config.admin);
        console2.log("upgrade admin owner", config.upgradeAdmin);
        console2.log("fundAHolder", config.fundAHolder);
        console2.log("liquidationOperator", config.liquidationOperator);
        console2.log("ETH/USD feed", config.ethUsdFeed);
        _printCollateralSummary(config.wbtcCollateral);
        _printCollateralSummary(config.wstethCollateral);
        console2.log("ICFT implementation", artifacts.icftImplementation);
        console2.log("ICFT proxy", artifacts.icftProxy);
        console2.log("ICFT proxy admin", artifacts.icftProxyAdmin);
        console2.log("PriceOracle implementation", artifacts.oracleImplementation);
        console2.log("PriceOracle proxy", artifacts.oracleProxy);
        console2.log("PriceOracle proxy admin", artifacts.oracleProxyAdmin);
        console2.log("InterestRateModel implementation", artifacts.rateModelImplementation);
        console2.log("InterestRateModel proxy", artifacts.rateModelProxy);
        console2.log("InterestRateModel proxy admin", artifacts.rateModelProxyAdmin);
        console2.log("RiskEngine implementation", artifacts.riskEngineImplementation);
        console2.log("RiskEngine proxy", artifacts.riskEngineProxy);
        console2.log("RiskEngine proxy admin", artifacts.riskEngineProxyAdmin);
        console2.log("LendingPool implementation", artifacts.lendingPoolImplementation);
        console2.log("LendingPool proxy", artifacts.lendingPoolProxy);
        console2.log("LendingPool proxy admin", artifacts.lendingPoolProxyAdmin);
        console2.log("LiquidationEngine implementation", artifacts.liquidationEngineImplementation);
        console2.log("LiquidationEngine proxy", artifacts.liquidationEngineProxy);
        console2.log("LiquidationEngine proxy admin", artifacts.liquidationEngineProxyAdmin);
        console2.log("Fund A allocation", config.fundAAllocation);
        console2.log("Liquidity buffer", config.liquidityBuffer);
        console2.log("Initial manual ICFT price", config.initialManualICFTPrice);
    }

    function _printCollateralSummary(CollateralConfig memory collateral) internal view {
        console2.log(string.concat(collateral.label, " enabled"), collateral.enabled);
        console2.log(string.concat(collateral.label, " asset"), collateral.asset);
        console2.log(string.concat(collateral.label, " feed"), collateral.usdFeed);
        console2.log(string.concat(collateral.label, " decimals"), uint256(collateral.assetDecimals));
    }

    function _configureCollateral(LendingPool lendingPool, PriceOracle oracle, CollateralConfig memory collateral) internal {
        if (!collateral.enabled) {
            return;
        }

        if (collateral.asset == address(0) || collateral.usdFeed == address(0)) {
            console2.log("WARNING: enabled collateral skipped due to missing asset or feed");
            console2.log("collateral", collateral.label);
            return;
        }

        oracle.setCollateralAssetFeed(collateral.asset, collateral.usdFeed, collateral.assetDecimals, true);
        lendingPool.setCollateralAsset(collateral.asset, true);
    }

    function _readProxyAdmin(address proxy) internal view returns (address admin) {
        admin = address(uint160(uint256(vm.load(proxy, ERC1967_ADMIN_SLOT))));
    }

    function _deployIcftProxy(DeploymentConfig memory config, ICFT implementation) internal returns (address) {
        return address(
            new TransparentUpgradeableProxy(
                address(implementation),
                config.upgradeAdmin,
                abi.encodeCall(
                    ICFT.initialize,
                    (
                        config.fundAHolder,
                        config.liquidityRecipient,
                        config.strategicReserveRecipient,
                        config.futureInvestorsRecipient,
                        config.founderRecipient,
                        config.developersRecipient,
                        config.ecosystemRecipient
                    )
                )
            )
        );
    }

    function _deployOracleProxy(DeploymentConfig memory config, PriceOracle implementation) internal returns (address) {
        return address(
            new TransparentUpgradeableProxy(
                address(implementation),
                config.upgradeAdmin,
                abi.encodeCall(
                    PriceOracle.initialize,
                    (
                        config.admin,
                        config.ethUsdFeed,
                        config.maxPriceAge,
                        config.initialManualICFTPrice,
                        config.initialManualICFTPriceDecimals
                    )
                )
            )
        );
    }

    function _deployRateModelProxy(
        DeploymentConfig memory config,
        InterestRateModel implementation,
        IInterestRateModel.RateConfig memory rateConfig
    ) internal returns (address) {
        return address(
            new TransparentUpgradeableProxy(
                address(implementation),
                config.upgradeAdmin,
                abi.encodeCall(InterestRateModel.initialize, (config.admin, rateConfig))
            )
        );
    }

    function _deployRiskEngineProxy(
        DeploymentConfig memory config,
        DeploymentArtifacts memory artifacts,
        RiskEngine implementation
    ) internal returns (address) {
        return address(
            new TransparentUpgradeableProxy(
                address(implementation),
                config.upgradeAdmin,
                abi.encodeCall(
                    RiskEngine.initialize,
                    (
                        config.admin,
                        artifacts.oracleProxy,
                        config.maxLtvBps,
                        config.liquidationThresholdBps,
                        config.targetLtvBps,
                        config.liquidationBonusBps
                    )
                )
            )
        );
    }

    function _deployLendingPoolProxy(
        DeploymentConfig memory config,
        DeploymentArtifacts memory artifacts,
        LendingPool implementation
    ) internal returns (address) {
        return address(
            new TransparentUpgradeableProxy(
                address(implementation),
                config.upgradeAdmin,
                abi.encodeCall(
                    LendingPool.initialize,
                    (
                        config.admin,
                        artifacts.icftProxy,
                        artifacts.oracleProxy,
                        artifacts.riskEngineProxy,
                        artifacts.rateModelProxy,
                        config.fundAAllocation,
                        config.liquidityBuffer
                    )
                )
            )
        );
    }

    function _deployLiquidationEngineProxy(
        DeploymentConfig memory config,
        DeploymentArtifacts memory artifacts,
        LiquidationEngine implementation
    ) internal returns (address) {
        return address(
            new TransparentUpgradeableProxy(
                address(implementation),
                config.upgradeAdmin,
                abi.encodeCall(
                    LiquidationEngine.initialize,
                    (config.admin, artifacts.icftProxy, artifacts.lendingPoolProxy)
                )
            )
        );
    }
}
