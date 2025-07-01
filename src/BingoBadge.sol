// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BingoBadge is ERC721URIStorage, Ownable {
    struct BingoItem {
        string data;
        bool completed;
    }

    struct BingoBoard {
        BingoItem[] items;
        string stage1_url;
        string stage2_url;
        string stage3_url;
        string stage4_url;
        string completed_url;
    }

    struct UserBingoBoard {
        uint256 boardIndex;
        bool completed;
        bool[25] completedItems;
        uint256 tokenId;
    }

    struct User {
        address userAddress;
        mapping(uint256 => UserBingoBoard) userBoards;
        uint256 boardCount;
    }

    mapping(address => User) public users;
    BingoBoard[] public bingoBoards;
    uint256 public nextTokenId;

    error Actions(string message);

    modifier isMember() {
        if (users[msg.sender].userAddress == address(0)) {
            revert Actions("Not a member");
        }
        _;
    }

    constructor() ERC721("Dev3PackBingoBadge", "D3B") Ownable(msg.sender) {}

    function addUser() public {
        if (users[msg.sender].userAddress != address(0)) {
            revert Actions("User already exists");
        }
        users[msg.sender].userAddress = msg.sender;
    }

    function addBingoBoard(
        BingoItem[] memory items,
        string memory s1,
        string memory s2,
        string memory s3,
        string memory s4,
        string memory done
    ) public onlyOwner {
        if (items.length != 25) revert Actions("Must have 25 items");

        bingoBoards.push();
        BingoBoard storage newBoard = bingoBoards[bingoBoards.length - 1];
        for (uint256 i = 0; i < 25; i++) {
            newBoard.items.push(BingoItem(items[i].data, false));
        }

        newBoard.stage1_url = s1;
        newBoard.stage2_url = s2;
        newBoard.stage3_url = s3;
        newBoard.stage4_url = s4;
        newBoard.completed_url = done;
    }

    function assignBoardToUser(uint256 boardIndex) public isMember {
        if (boardIndex >= bingoBoards.length) revert Actions("Invalid board");

        User storage user = users[msg.sender];
        uint256 id = user.boardCount++;

        user.userBoards[id].boardIndex = boardIndex;
        user.userBoards[id].completed = false;
        user.userBoards[id].tokenId = 0;
    }

    function markItemCompleted(uint256 userBoardIndex, uint256 itemIndex) public isMember {
        User storage user = users[msg.sender];
        UserBingoBoard storage ub = user.userBoards[userBoardIndex];

        if (itemIndex >= 25) revert Actions("Invalid item index");
        if (ub.completedItems[itemIndex]) revert Actions("Item already done");

        ub.completedItems[itemIndex] = true;
        _updateNFTProgress(userBoardIndex);
    }

    function _updateNFTProgress(uint256 userBoardIndex) internal {
        User storage user = users[msg.sender];
        UserBingoBoard storage ub = user.userBoards[userBoardIndex];
        BingoBoard storage board = bingoBoards[ub.boardIndex];

        uint256 completedCount = 0;
        for (uint256 i = 0; i < 25; i++) {
            if (ub.completedItems[i]) completedCount++;
        }

        string memory uri;

        if (ub.tokenId == 0) {
            uint256 newId = ++nextTokenId;
            _safeMint(msg.sender, newId);
            ub.tokenId = newId;
        }

        if (completedCount == 25) {
            ub.completed = true;
            uri = board.completed_url;
        } else {
            uint256 lines = _countCompletedLines(ub);
            if (lines >= 4) uri = board.stage4_url;
            else if (lines >= 3) uri = board.stage3_url;
            else if (lines >= 2) uri = board.stage2_url;
            else uri = board.stage1_url;
        }

        _setTokenURI(ub.tokenId, uri);
    }

    function _countCompletedLines(UserBingoBoard storage ub) internal view returns (uint256) {
        uint256 lines = 0;

        // Rows
        for (uint256 i = 0; i < 5; i++) {
            bool complete = true;
            for (uint256 j = 0; j < 5; j++) {
                if (!ub.completedItems[i * 5 + j]) {
                    complete = false;
                    break;
                }
            }
            if (complete) lines++;
        }

        // Columns
        for (uint256 i = 0; i < 5; i++) {
            bool complete = true;
            for (uint256 j = 0; j < 5; j++) {
                if (!ub.completedItems[j * 5 + i]) {
                    complete = false;
                    break;
                }
            }
            if (complete) lines++;
        }

        // Diagonals
        bool diag1 = true;
        bool diag2 = true;
        for (uint256 i = 0; i < 5; i++) {
            if (!ub.completedItems[i * 6]) diag1 = false;
            if (!ub.completedItems[(i + 1) * 4]) diag2 = false;
        }

        if (diag1) lines++;
        if (diag2) lines++;

        return lines;
    }

    function getUserBoardStatus(uint256 boardIndex) public view isMember returns (bool[25] memory) {
        User storage user = users[msg.sender];
        UserBingoBoard storage ub = user.userBoards[boardIndex];

        bool[25] memory status;
        for (uint256 i = 0; i < 25; i++) {
            status[i] = ub.completedItems[i];
        }
        return status;
    }
}
