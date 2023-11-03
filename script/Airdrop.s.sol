// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Airdrop} from "../src/Airdrop.sol";

/// @title A script for deploying the Airdrop contract
/// @notice This script uses the Foundry toolchain to deploy an instance of the Airdrop contract
contract CounterScript is Script {
    Airdrop public aidrop;

    /// @notice Sets up the script, can be used to set initial state before the main script is run
    /// @dev The setUp function is empty in this script, as no initial setup is required
    function setUp() public {}

    /// @notice Deploys the Airdrop contract
    /// @dev Uses vm.broadcast() to send the deployment transaction
    function run() public {
        vm.broadcast();
        aidrop = new Airdrop();
    }
}
