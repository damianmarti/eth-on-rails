// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DeployHelpers.s.sol";
import { DeployYourContract } from "./DeployYourContract.s.sol";

/**
 * @notice Main deployment script for all contracts
 * @dev Run this when you want to deploy multiple contracts at once
 *
 * Example: yarn deploy # runs this script (without`--file` flag)
 */
contract DeployScript is ScaffoldETHDeploy {
    function run() external {
        DeployYourContract deployYourContract = new DeployYourContract();
        deployYourContract.run();

        // Deploy another contract here, e.g.
        // DeployMyContract deployMyContract = new DeployMyContract();
        // deployMyContract.run();
    }
}
