// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { YourContract } from "../contracts/YourContract.sol";

contract YourContractTest is Test {
    YourContract public yourContract;

    function setUp() public {
        yourContract = new YourContract(vm.addr(1));
    }

    function testMessageOnDeploy() public view {
        assertEq(yourContract.greeting(), "Building Unstoppable Apps!!!");
    }

    function testSetGreeting() public {
        yourContract.setGreeting("Learn Scaffold-ETH on Rails! :)");
        assertEq(yourContract.greeting(), "Learn Scaffold-ETH on Rails! :)");
    }

    function testTotalCounterIncrements() public {
        uint256 before = yourContract.totalCounter();
        yourContract.setGreeting("counting");
        assertEq(yourContract.totalCounter(), before + 1);
    }
}
