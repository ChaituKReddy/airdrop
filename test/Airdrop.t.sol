// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Test, console2} from "forge-std/Test.sol";
import {Airdrop} from "../src/Airdrop.sol";
import {ERC20Token} from "../src/Mocks/ERC20.sol";
import {Receiver} from "../src/Mocks/Receive.sol";
import {NFT} from "../src/Mocks/ERC721.sol";

/// @title A testing contract for Airdrop functionality using Foundry
/// @notice This contract is used to test the airdrop functionality for both native ETH and ERC20 tokens
contract CounterTest is Test {
    Airdrop public airdrop;

    ERC20Token public token;
    Receiver public receiver;

    NFT public nft;

    address public Alice = makeAddr("Alice");
    address public Bob = makeAddr("Bob");

    address[] public _users;
    uint256[] public _amounts;
    uint256[] public _tokenIds;

    address[] public _wrongUsers;
    uint256[] public _wrongAmounts;

    /// @notice Setup function to initialize test contract instances and state variables
    function setUp() public {
        airdrop = new Airdrop();

        token = new ERC20Token(type(uint256).max, "Airdrop Token", 18, "ADT");
        receiver = new Receiver();

        nft = new NFT("Airdrop NFT", "ANFT", "", msg.sender, 1000);
        nft.batchMint(Bob, 1000, "");

        vm.deal(Alice, 1_000_000 ether);
        vm.deal(Bob, 1_000_000 ether);
        vm.deal(address(token), 1_000_000 ether);
        vm.deal(address(receiver), 1_000_000 ether);

        for (uint256 i; i < 100; ++i) {
            uint256 value = i + 200;
            _users.push(address(uint160(value)));
            _amounts.push((i + 1) * 1 ether);
            _tokenIds.push(i + 1);

            _wrongUsers.push(address(uint160(value)));

            if (i % 2 == 0) _wrongAmounts.push((i + 1) * 1 ether);
        }
    }

    /// @notice Tests the airdrop of native ETH to ensure correct functionality
    /// @dev Simulates various scenarios including reverts and successful transfers
    function testAirDropNative() external {
        vm.startPrank(Alice);

        // Revert on Length Mismatch
        vm.expectRevert(abi.encodeWithSignature("ArrayLengthMismatch()"));
        airdrop.airdropNative{value: 5050 ether}(_wrongUsers, _wrongAmounts);

        // Exact amount of ETH
        airdrop.airdropNative{value: 5050 ether}(_users, _amounts);

        assertEq(
            address(200).balance,
            1 ether,
            "Balance to 1st address not sent properly"
        );

        assertEq(
            address(272).balance,
            73 ether,
            "Balance to random address in middle not sent properly"
        );

        assertEq(
            address(299).balance,
            100 ether,
            "Balance to last address not sent properly"
        );

        assertEq(
            Alice.balance,
            (1_000_000 - 5050) * 1 ether,
            "Alice balance didn't update properly"
        );

        // Less amount of ETH
        vm.expectRevert(abi.encodeWithSignature("NativeTransferFailed()"));
        // vm.expectRevert(bytes4(keccak256("NativeTransferFailed()")));
        airdrop.airdropNative{value: 5049 ether}(_users, _amounts);

        vm.stopPrank();

        vm.startPrank(address(token));
        // Revert when it can't transfer the excess back
        vm.expectRevert(
            abi.encodeWithSignature("NativeTransferExcessFailed()")
        );
        airdrop.airdropNative{value: 100_000 ether}(_users, _amounts);

        // It should not revert for contract with no fallback when sending exact amount
        bool status = airdrop.airdropNative{value: 5050 ether}(
            _users,
            _amounts
        );

        assertEq(
            status,
            true,
            "Transfer failed for contract with no fallback when sending exact amount"
        );

        vm.stopPrank();

        vm.startPrank(address(receiver));

        //it should allow transfer of excess
        status = airdrop.airdropNative{value: 5051 ether}(_users, _amounts);
        assertEq(
            status,
            true,
            "Transfer failed for contract with receive when sending excess amount"
        );
        assertEq(
            address(receiver).balance,
            (1_000_000 - 5050) * 1 ether,
            "Alice balance didn't update properly"
        );
    }

    /// @notice Tests the airdrop of ERC20 tokens to ensure correct functionality
    /// @dev Simulates various scenarios including reverts and successful transfers
    function testAirDropERC20() external {
        token.transfer(Alice, type(uint256).max);

        vm.startPrank(Alice);

        // Revert on Length Mismatch
        vm.expectRevert(abi.encodeWithSignature("ArrayLengthMismatch()"));
        airdrop.airdropERC20(address(token), _wrongUsers, _wrongAmounts);

        //Revert on correct data but no allowance
        vm.expectRevert(
            "token balance or _allowance is lower than amount requested"
        );
        airdrop.airdropERC20(address(token), _users, _amounts);

        (token).approve(address(airdrop), 1_000_000 ether);

        bool status = airdrop.airdropERC20(address(token), _users, _amounts);
        assertEq(status, true, "Aidrop of ERC20 not successful");

        assertEq(
            (token).balanceOf(address(200)),
            1 ether,
            "Balance to 1st address not sent properly"
        );

        assertEq(
            (token).balanceOf(address(272)),
            73 ether,
            "Balance to random address in middle not sent properly"
        );

        assertEq(
            (token).balanceOf(address(299)),
            100 ether,
            "Balance to last address not sent properly"
        );

        assertEq(
            (token).balanceOf(Alice),
            (type(uint256).max - (5050 * 1 ether)),
            "Alice balance didn't update properly"
        );

        assertEq(
            (token).allowance(Alice, address(airdrop)),
            (1_000_000 - 5050) * 1 ether,
            "Alice allowance didn't update properly"
        );

        address[] memory _newUser = new address[](1);
        uint256[] memory _newAmount = new uint256[](1);

        _newUser[0] = address(10_000);
        _newAmount[0] = 100 ether;

        vm.expectRevert(abi.encodeWithSignature("ERC20TransferFailed()"));
        airdrop.airdropERC20(address(token), _newUser, _newAmount); // Check the ERC20 transferFrom function to understand this fail case

        vm.stopPrank();
    }

    function testAirdropERC721() external {
        vm.startPrank(Bob);

        // Should revert on len mismatch
        vm.expectRevert(abi.encodeWithSignature("ArrayLengthMismatch()"));
        airdrop.airdropERC721(address(nft), _wrongUsers, _wrongAmounts);

        // Revert on correct data but no allowance
        vm.expectRevert("ERC721: caller is not token owner or approved");
        airdrop.airdropERC721(address(nft), _users, _tokenIds);

        nft.setApprovalForAll(address(airdrop), true);

        airdrop.airdropERC721(address(nft), _users, _tokenIds);

        assertEq(
            nft.ownerOf(1),
            address(200),
            "Owner didn't change for first tokenId"
        );

        assertEq(
            nft.ownerOf(100),
            address(299),
            "Owner didn't change for last tokenId"
        );

        assertEq(
            nft.ownerOf(72),
            address(271),
            "Owner didn't change for last tokenId"
        );

        address[] memory _newUser = new address[](1);
        uint256[] memory _newTokenId = new uint256[](1);

        _newUser[0] = address(token);
        _newTokenId[0] = 982;

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");
        airdrop.airdropERC721(address(nft), _newUser, _newTokenId);

        _newUser[0] = address(0);
        vm.expectRevert("ERC721: transfer to the zero address");
        airdrop.airdropERC721(address(nft), _newUser, _newTokenId);
    }

    function testAirdropERC721K() external {
        vm.startPrank(Bob);

        // Revert on correct data but no allowance
        vm.expectRevert("ERC721: caller is not token owner or approved");
        airdrop.airdropERC721(address(nft), Alice, _tokenIds);

        nft.setApprovalForAll(address(airdrop), true);

        airdrop.airdropERC721(address(nft), Alice, _tokenIds);

        assertEq(
            nft.ownerOf(1),
            Alice,
            "Owner didn't change for first tokenId"
        );

        assertEq(
            nft.ownerOf(100),
            Alice,
            "Owner didn't change for last tokenId"
        );

        assertEq(
            nft.ownerOf(72),
            Alice,
            "Owner didn't change for last tokenId"
        );

        uint256[] memory _newTokenId = new uint256[](1);

        _newTokenId[0] = 982;

        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");
        airdrop.airdropERC721(address(nft), address(token), _newTokenId);

        vm.expectRevert("ERC721: transfer to the zero address");
        airdrop.airdropERC721(address(nft), address(0), _newTokenId);
    }
}
