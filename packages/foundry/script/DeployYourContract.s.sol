// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DeployHelpers.s.sol";
import { YourContract } from "../contracts/YourContract.sol";

contract DeployYourContract is ScaffoldETHDeploy {
    function run() external ScaffoldEthDeployerRunner {
        YourContract yourContract = new YourContract(deployer);
        console.logString(
            string.concat("YourContract deployed at: ", vm.toString(address(yourContract)))
        );
    }
}
