//SPDX-Licence-Identifier: MIT

pragma solidity 0.8.21;

interface IERC20 {
    function transferFrom(
        address sender,
        address receiver,
        uint256 amount
    ) external returns (bool);
}

contract Airdrop {
    error ArrayLengthMismatch();
    error NativeTransferFailed();
    error NativeTransferExcessFailed();
    error ERC20TransferFailed();

    function airdropNative(
        address[] calldata _users,
        uint256[] calldata _amounts
    ) external payable returns (bool) {
        uint256 len = _users.length;
        if (len != _amounts.length) revert ArrayLengthMismatch();

        uint256 totalValue;

        for (uint256 i; i < len; ++i) {
            totalValue += _amounts[i];
            (bool success, ) = payable(_users[i]).call{value: _amounts[i]}("");
            if (!success) revert NativeTransferFailed();
        }

        if (totalValue < msg.value) {
            (bool success, ) = payable(msg.sender).call{
                value: msg.value - totalValue
            }("");
            if (!success) revert NativeTransferExcessFailed();
        }

        return true;
    }

    function airdropERC20(
        address _token,
        address[] calldata _users,
        uint256[] calldata _amounts
    ) external returns (bool) {
        uint256 len = _users.length;
        if (len != _amounts.length) revert ArrayLengthMismatch();

        for (uint256 i; i < len; ++i) {
            bool success = IERC20(_token).transferFrom(
                msg.sender,
                _users[i],
                _amounts[i]
            );
            if (!success) revert ERC20TransferFailed();
        }
        return true;
    }
}
