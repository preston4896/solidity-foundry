// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {VmSafe} from "forge-std/Vm.sol";

abstract contract DeploymentConfig is Script {
    function readContractAddress(string memory contractName, bool revertOnAddressZero)
        internal
        view
        returns (address contractAddress)
    {
        string memory deploymentDir =
            string.concat(vm.projectRoot(), "/", "deployment", "/", vm.toString(block.chainid), ".json");
        if (!vm.exists(deploymentDir)) {
            revert("Cannot find deployment file");
        }
        string memory jsonStr = vm.readFile(deploymentDir);
        string memory key = string.concat(".", contractName);
        bool keyExists = vm.keyExists(jsonStr, key);
        if (keyExists) {
            contractAddress = stdJson.readAddress(jsonStr, key);
        }
        if (revertOnAddressZero && contractAddress == address(0)) {
            revert(string.concat("Address for ", contractName, " is zero"));
        }
    }

    function writeToJson(string memory contractName, address contractAddress) internal {
        bool isBroadcasting = vm.isContext(VmSafe.ForgeContext.ScriptBroadcast);
        
        if (isBroadcasting) {
            string memory deploymentDir = string.concat(vm.projectRoot(), "/", "deployment");

            // check dir exists
            if (!vm.exists(deploymentDir)) {
                vm.createDir(deploymentDir, false);
            }

            // deployment path
            string memory jsonPath = string.concat(deploymentDir, "/", vm.toString(block.chainid), ".json");

            string memory jsonKey = "deployment key";
            string memory jsonStr = "";
            if (vm.exists(jsonPath)) {
                jsonStr = vm.readFile(jsonPath);
                vm.serializeJson(jsonKey, jsonStr);
            }

            string memory finalJson = vm.serializeAddress(jsonKey, contractName, contractAddress);
            vm.writeJson(finalJson, jsonPath);
        } else {
            console.log("Not broadcasting, skip writing to JSON");
        }
    }
}
