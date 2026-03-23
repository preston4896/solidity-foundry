// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {Calculator} from "../src/Calculator.sol";
import {DeploymentConfig} from "./utils/DeploymentConfig.sol";
import {CALCULATOR_SALT} from "./utils/Salt.sol";

contract CalculatorScript is Script, DeploymentConfig {
    function run() external {
        vm.startBroadcast();

        Calculator calculator = new Calculator{salt: CALCULATOR_SALT}(4896);
        console.log("Calculator deployed at: ", address(calculator));

        vm.stopBroadcast();

        writeToJson("Calculator", address(calculator));
    }
}
