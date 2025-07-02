// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {BingoBadge} from "./../src/BingoBadge.sol";

contract Bingo is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        BingoBadge bingoBadge = new BingoBadge();
        console.log("BingoBadge deployed at:", address(bingoBadge));
        vm.stopBroadcast();
    }
}
