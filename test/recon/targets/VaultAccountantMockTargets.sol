// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Properties} from "../Properties.sol";
// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";

import "test/HypoVault.t.sol";

abstract contract VaultAccountantMockTargets is
    BaseTargetFunctions,
    Properties
{
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///


    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///

    function vaultAccountantMock_setExpectedManagerInput(bytes memory _expectedManagerInput) public asActor {
        vaultAccountantMock.setExpectedManagerInput(_expectedManagerInput);
    }

    function vaultAccountantMock_setExpectedVault(address _expectedVault) public asActor {
        vaultAccountantMock.setExpectedVault(_expectedVault);
    }

    function vaultAccountantMock_setNav(uint256 _nav) public asActor {
        vaultAccountantMock.setNav(_nav);
    }
}