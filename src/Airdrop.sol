// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title Minimal Interface for the ERC20 standard.
interface IERC20 {
    /// @dev Moves `amount` tokens from `sender` to `receiver`.
    /// @param sender The address from which the tokens are transferred.
    /// @param receiver The address to which the tokens are transferred.
    /// @param amount The number of tokens to transfer.
    /// @return success A boolean value indicating whether the transfer succeeded.
    function transferFrom(
        address sender,
        address receiver,
        uint256 amount
    ) external returns (bool);
}

interface IERC721 {
    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;
}

/// @title Airdrop contract for distributing native currency or ERC20 tokens.
/// @author deadDosa
contract Airdrop {
    /// @dev Emitted when the length of users array doesn't match the length of amounts array.
    error ArrayLengthMismatch();

    /// @dev Emitted when the transfer of native currency to a recipient fails.
    error NativeTransferFailed();

    /// @dev Emitted when returning excess native currency to the sender fails.
    error NativeTransferExcessFailed();

    /// @dev Emitted when the transfer of ERC20 tokens to a recipient fails.
    error ERC20TransferFailed();

    /// @notice Distributes native currency to a list of recipients.
    /// @param _users The array of recipient addresses.
    /// @param _amounts The array of amounts to send to the respective recipient addresses.
    /// @return success A boolean value indicating whether the airdrop succeeded.
    function airdropNative(
        address[] calldata _users,
        uint256[] calldata _amounts
    ) external payable returns (bool) {
        uint256 len = _users.length;
        if (len != _amounts.length) revert ArrayLengthMismatch();

        uint256 totalValue;

        for (uint256 i; i < len; ) {
            totalValue += _amounts[i];
            (bool success, ) = payable(_users[i]).call{value: _amounts[i]}("");
            if (!success) revert NativeTransferFailed();

            unchecked {
                ++i;
            }
        }

        if (totalValue < msg.value) {
            (bool success, ) = payable(msg.sender).call{
                value: msg.value - totalValue
            }("");
            if (!success) revert NativeTransferExcessFailed();
        }

        return true;
    }

    /// @notice Distributes ERC20 tokens to a list of recipients.
    /// @param _token The ERC20 token address that will be airdropped.
    /// @param _users The array of recipient addresses.
    /// @param _amounts The array of amounts of the token to send to the respective recipient addresses.
    /// @return success A boolean value indicating whether the airdrop succeeded.
    function airdropERC20(
        address _token,
        address[] calldata _users,
        uint256[] calldata _amounts
    ) external returns (bool) {
        uint256 len = _users.length;
        if (len != _amounts.length) revert ArrayLengthMismatch();

        for (uint256 i; i < len; ) {
            bool success = IERC20(_token).transferFrom(
                msg.sender,
                _users[i],
                _amounts[i]
            );
            if (!success) revert ERC20TransferFailed();

            unchecked {
                ++i;
            }
        }
        return true;
    }

    function airdropERC721(
        address _token,
        address[] calldata _users,
        uint256[] calldata _tokenIds
    ) external returns (bool) {
        uint256 len = _users.length;
        if (len != _tokenIds.length) revert ArrayLengthMismatch();

        for (uint256 i; i < len; ) {
            IERC721(_token).safeTransferFrom(
                msg.sender,
                _users[i],
                _tokenIds[i]
            );

            unchecked {
                ++i;
            }
        }
        return true;
    }

    function airdropERC721(
        address _token,
        address _user,
        uint256[] calldata _tokenIds
    ) external returns (bool) {
        uint256 len = _tokenIds.length;

        for (uint256 i; i < len; ) {
            IERC721(_token).safeTransferFrom(msg.sender, _user, _tokenIds[i]);

            unchecked {
                ++i;
            }
        }
        return true;
    }
}
