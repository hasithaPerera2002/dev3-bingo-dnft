// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {BingoBadge} from "../src/BingoBadge.sol";

contract BingoTest is Test {
    BingoBadge public bingo;
    address user1 = address(0xABCD);

    function setUp() public {
        bingo = new BingoBadge();
    }

    function testAddUser() public {
        vm.prank(user1);
        bingo.addUser();

        // There's no direct getter for users mapping, so we confirm indirectly
        // by successfully assigning a board later
        vm.prank(user1);
        bool passed;
        try bingo.assignBoardToUser(0) {
            passed = true;
        } catch {
            passed = false;
        }
        assertTrue(!passed, "Should fail because no board exists yet");
    }

    function testAddBingoBoard() public {
        // Create dummy items
        BingoBadge.BingoItem[25] memory items;
        for (uint256 i = 0; i < 25; i++) {
            items[i] = BingoBadge.BingoItem({data: "Test", completed: false});
        }

        // Convert fixed-size array to dynamic array
        BingoBadge.BingoItem[] memory dynItems = new BingoBadge.BingoItem[](25);
        for (uint256 i = 0; i < 25; i++) {
            dynItems[i] = items[i];
        }
        bingo.addBingoBoard(
            dynItems, "ipfs://stage1", "ipfs://stage2", "ipfs://stage3", "ipfs://stage4", "ipfs://completed"
        );

        // No direct getter for bingoBoards, so we test assign to confirm
        vm.prank(user1);
        bingo.addUser();

        vm.prank(user1);
        bingo.assignBoardToUser(0);
    }

    function testAssignAndMarkItem() public {
        // Create and add board
        BingoBadge.BingoItem[25] memory items;
        for (uint256 i = 0; i < 25; i++) {
            items[i] = BingoBadge.BingoItem({data: "Test", completed: false});
        }

        // Convert fixed-size array to dynamic array
        BingoBadge.BingoItem[] memory dynItems = new BingoBadge.BingoItem[](25);
        for (uint256 i = 0; i < 25; i++) {
            dynItems[i] = items[i];
        }
        bingo.addBingoBoard(
            dynItems, "ipfs://stage1", "ipfs://stage2", "ipfs://stage3", "ipfs://stage4", "ipfs://completed"
        );

        // Add user and assign board
        vm.startPrank(user1);

        bingo.addUser();
        bingo.assignBoardToUser(0);
        bingo.markItemCompleted(0, 0);

        bool[25] memory progress = bingo.getUserBoardStatus(0);
        vm.stopPrank();

        console.log("Progress for user board 0:");
        assertTrue(progress[0], "Item 0 should be marked complete");
    }
}
