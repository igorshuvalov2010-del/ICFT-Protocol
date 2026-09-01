// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {ICFT} from "../src/core/ICFT/token/ICFT.sol";
import {PriceOracle} from "../src/core/ICFT/oracle/PriceOracle.sol";
import {InterestRateModel} from "../src/core/ICFT/lending/InterestRateModel.sol";
import {LendingPool} from "../src/core/ICFT/lending/LendingPool.sol";
import {LiquidationEngine} from "../src/core/ICFT/lending/LiquidationEngine.sol";
import {RiskEngine} from "../src/core/ICFT/risk/RiskEngine.sol";

contract UpgradeICFTModule is Script {
    struct UpgradeConfig {
        address proxyAdmin;
        address proxy;
        string module;
        bytes initCalldata;
    }

    function run() external returns (address newImplementation) {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        UpgradeConfig memory config = _loadConfig();

        vm.startBroadcast(deployerPrivateKey);

        newImplementation = _deployImplementation(config.module);
        ProxyAdmin(config.proxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(payable(config.proxy)), newImplementation, config.initCalldata
        );

        vm.stopBroadcast();

        console2.log("=== ICFT Proxy Upgrade Summary ===");
        console2.log("module", config.module);
        console2.log("proxyAdmin", config.proxyAdmin);
        console2.log("proxy", config.proxy);
        console2.log("newImplementation", newImplementation);
        console2.log("initCalldataLength", config.initCalldata.length);
    }

    function _loadConfig() internal view returns (UpgradeConfig memory config) {
        config.proxyAdmin = vm.envAddress("PROXY_ADMIN_ADDRESS");
        config.proxy = vm.envAddress("PROXY_ADDRESS");
        config.module = vm.envString("MODULE");
        config.initCalldata = vm.envOr("UPGRADE_CALLDATA", bytes(""));
    }

    function _deployImplementation(string memory module) internal returns (address implementation) {
        bytes32 moduleHash = keccak256(bytes(module));

        if (moduleHash == keccak256("ICFT")) {
            return address(new ICFT());
        }
        if (moduleHash == keccak256("PriceOracle")) {
            return address(new PriceOracle());
        }
        if (moduleHash == keccak256("InterestRateModel")) {
            return address(new InterestRateModel());
        }
        if (moduleHash == keccak256("RiskEngine")) {
            return address(new RiskEngine());
        }
        if (moduleHash == keccak256("LendingPool")) {
            return address(new LendingPool());
        }
        if (moduleHash == keccak256("LiquidationEngine")) {
            return address(new LiquidationEngine());
        }

        revert(string.concat("Unsupported MODULE: ", module));
    }
}
