// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";

/**
 * @notice Base contract for ETH-on-Rails Foundry deployments.
 *
 * Provides deployer-key resolution and a broadcast modifier. The canonical
 * record of what was deployed lives in Foundry's own `broadcast/<script>/<chainId>/run-latest.json`
 * (contract name + address per CREATE tx). The JS generator
 * (`scripts-js/generateContractsJson.js`) reads that file plus the compiled
 * ABIs in `out/` to produce the Rails artifact.
 */
contract ScaffoldETHDeploy is Script {
    uint256 internal deployerPrivateKey;
    address internal deployer;

    /// @dev Local chains default to anvil/hardhat account #0; live chains use DEPLOYER_PRIVATE_KEY.
    function _getDeployerKey() internal view returns (uint256) {
        if (block.chainid == 31337) {
            return 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        }
        return vm.envUint("DEPLOYER_PRIVATE_KEY");
    }

    modifier ScaffoldEthDeployerRunner() {
        deployerPrivateKey = _getDeployerKey();
        deployer = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);
        _;
        vm.stopBroadcast();
    }
}
