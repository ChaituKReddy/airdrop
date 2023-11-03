// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title A minimalistic smart contract to receive Ether
contract Receiver {
    /// @notice Accepts incoming Ether transactions
    receive() external payable {}
}
