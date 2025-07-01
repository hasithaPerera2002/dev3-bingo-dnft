// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {BingoBadge} from "./../src/BingoBadge.sol";

contract Bingo is Script {
    BingoBadge bingoBadge;

    function setUp() public {
        bingoBadge = new BingoBadge();
    }

    function run() public {
        vm.startBroadcast();
        console.log("BingoBadge deployed at:", address(bingoBadge));
        vm.stopBroadcast();
    }
}
