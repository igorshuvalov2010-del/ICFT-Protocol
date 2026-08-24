// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {ICFT} from "../src/core/ICFT/token/ICFT.sol";
import {PriceOracle} from "../src/core/ICFT/oracle/PriceOracle.sol";
import {InterestRateModel} from "../src/core/ICFT/lending/InterestRateModel.sol";
import {LendingPool} from "../src/core/ICFT/lending/LendingPool.sol";
import {LiquidationEngine} from "../src/core/ICFT/lending/LiquidationEngine.sol";
import {RiskEngine} from "../src/core/ICFT/risk/RiskEngine.sol";
import {IInterestRateModel} from "../src/core/interfaces/IInterestRateModel.sol";

contract DeployICFTProtocol is Script {
    struct DeploymentConfig {
        address admin;
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
    }

    function run() external returns (
        ICFT icft,
        PriceOracle oracle,
        InterestRateModel rateModel,
        RiskEngine riskEngine,
        LendingPool lendingPool,
        LiquidationEngine liquidationEngine
    ) {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        DeploymentConfig memory config = _loadConfig(deployer);

        vm.startBroadcast(deployerPrivateKey);

        icft = new ICFT(
            config.fundAHolder,
            config.liquidityRecipient,
            config.strategicReserveRecipient,
            config.futureInvestorsRecipient,
            config.founderRecipient,
            config.developersRecipient,
            config.ecosystemRecipient
        );

        oracle = new PriceOracle(
            config.admin,
            config.ethUsdFeed,
            config.maxPriceAge,
            config.initialManualICFTPrice,
            config.initialManualICFTPriceDecimals
        );

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
        rateModel = new InterestRateModel(config.admin, rateConfig);

        riskEngine = new RiskEngine(
            config.admin,
            address(oracle),
            config.maxLtvBps,
            config.liquidationThresholdBps,
            config.targetLtvBps,
            config.liquidationBonusBps
        );

        lendingPool = new LendingPool(
            config.admin,
            address(icft),
            address(oracle),
            address(riskEngine),
            address(rateModel),
            config.fundAAllocation,
            config.liquidityBuffer
        );

        liquidationEngine = new LiquidationEngine(config.admin, address(icft), address(lendingPool));

        lendingPool.grantRole(lendingPool.LIQUIDATION_BOT_ROLE(), address(liquidationEngine));
        liquidationEngine.grantRole(liquidationEngine.OPERATOR_ROLE(), config.liquidationOperator);

        vm.stopBroadcast();

        if (config.fundAHolder == deployer) {
            vm.startBroadcast(deployerPrivateKey);
            icft.transfer(address(lendingPool), config.fundAAllocation);
            vm.stopBroadcast();
        } else {
            console2.log("WARNING: FUND_A_HOLDER is not the deployer.");
            console2.log("Transfer Fund A allocation manually to LendingPool:", address(lendingPool));
        }

        _printDeploymentSummary(
            config,
            address(icft),
            address(oracle),
            address(rateModel),
            address(riskEngine),
            address(lendingPool),
            address(liquidationEngine)
        );
    }

    function _loadConfig(address deployer) internal view returns (DeploymentConfig memory config) {
        config.admin = vm.envOr("ADMIN_ADDRESS", deployer);
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
    }

    function _printDeploymentSummary(
        DeploymentConfig memory config,
        address icft,
        address oracle,
        address rateModel,
        address riskEngine,
        address lendingPool,
        address liquidationEngine
    ) internal view {
        console2.log("=== ICFT Protocol Deployment Summary ===");
        console2.log("chainid", block.chainid);
        console2.log("admin", config.admin);
        console2.log("fundAHolder", config.fundAHolder);
        console2.log("liquidationOperator", config.liquidationOperator);
        console2.log("ETH/USD feed", config.ethUsdFeed);
        console2.log("ICFT", icft);
        console2.log("PriceOracle", oracle);
        console2.log("InterestRateModel", rateModel);
        console2.log("RiskEngine", riskEngine);
        console2.log("LendingPool", lendingPool);
        console2.log("LiquidationEngine", liquidationEngine);
        console2.log("Fund A allocation", config.fundAAllocation);
        console2.log("Liquidity buffer", config.liquidityBuffer);
        console2.log("Initial manual ICFT price", config.initialManualICFTPrice);
    }
}
