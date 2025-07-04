// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";

// Targets
// NOTE: Always import and apply them in alphabetical order, so much easier to debug!
import {AdminTargets} from "./targets/AdminTargets.sol";
import {DoomsdayTargets} from "./targets/DoomsdayTargets.sol";
import {HypoVaultTargets} from "./targets/HypoVaultTargets.sol";
import {ManagersTargets} from "./targets/ManagersTargets.sol";

abstract contract TargetFunctions is AdminTargets, DoomsdayTargets, HypoVaultTargets, ManagersTargets {
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///

    function hypoVault_executeDeposit_clamped_multiple_gh(uint256 epoch)
        public
        updateGhostsWithType(OpType.EXECUTE_DEPOSIT)
        asActorEntropy(1)
    {
        require(epoch < hypoVault.depositEpoch());
        hypoVault.executeDeposit(_getActor(), epoch);
    }

    function hypoVault_executeDeposit_clamped_multiple(address user, uint256 epoch) public asActorEntropy(1) {
        require(epoch < hypoVault.depositEpoch());
        hypoVault.executeDeposit(user, epoch);
    }

    function hypoVault_approve_multiple(address spender, uint256 amount) public asActorEntropy(1) {
        hypoVault.approve(spender, amount);
    }

    function hypoVault_executeDeposit_multiple(address user, uint256 epoch) public asActorEntropy(1) {
        hypoVault.executeDeposit(user, epoch);
    }

    function hypoVault_executeWithdrawal_multiple(address user, uint256 epoch) public asActorEntropy(1) {
        hypoVault.executeWithdrawal(user, epoch);
    }

    function hypoVault_requestDeposit_multiple(uint128 assets) public asActorEntropy(1) {
        hypoVault.requestDeposit(assets);
    }

    function hypoVault_requestWithdrawal_multiple(uint128 shares) public asActorEntropy(1) {
        hypoVault.requestWithdrawal(shares);
    }

    function hypoVault_transfer_multiple(address to, uint256 amount) public asActorEntropy(1) {
        hypoVault.transfer(to, amount);
    }

    function hypoVault_transferFrom_multiple(address from, address to, uint256 amount) public asActorEntropy(1) {
        hypoVault.transferFrom(from, to, amount);
    }
    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///
}
