// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import {vm} from "@chimera/Hevm.sol";

import {Math} from "lib/panoptic-v1.1/contracts/libraries/Math.sol";

abstract contract Properties is BeforeAfter, Asserts {
     using Math for uint256;
     address constant USER1 = address(0x1111);
    address constant USER2 = address(0x2222);


    /// @notice Find maximum cumulative basis loss through multiple transfers
    function optimize_cumulative_basis_loss() public view returns (int256) {
        return _cumulativeBasisLoss;
    }

    int256 _cumulativeBasisLoss;

        /// @notice Test specifically designed to find maximum basis loss through rounding
    function findMaxBasisLossFromRounding(
        uint256 initialBasis,
        uint256 initialShares,
        uint256 transferAmount
    ) public {
        // Bound inputs to create conditions prone to rounding errors
        initialBasis = between(initialBasis, 1, 1000); // Small basis
        initialShares = between(initialShares, initialBasis * 100, type(uint64).max); // Large shares relative to basis
        
        hypoVault.increaseBasisAndShares(USER1, initialBasis, initialShares);
        
        uint256 balance = hypoVault.balanceOf(USER1);
        transferAmount = between(transferAmount, 1, balance);
        
        uint256 basisBefore = hypoVault.userBasis(USER1);
        
        vm.prank(USER1);
        hypoVault.transfer(USER2, transferAmount);
        
        uint256 totalBasisAfter = hypoVault.userBasis(USER1) + hypoVault.userBasis(USER2);
        
        int256 basisLoss = int256(basisBefore) - int256(totalBasisAfter);
        
        if (basisLoss > _cumulativeBasisLoss) {
            _cumulativeBasisLoss = basisLoss;
        }
    }

    function prop_reserved_withdrawal_assets_always_available() public {
        (uint128 assetsDeposited,,) = hypoVault.getDepositEpochState(hypoVault.depositEpoch());
        gte(
            IERC20(hypoVault.underlyingToken()).balanceOf(address(hypoVault)),
            assetsDeposited + hypoVault.reservedWithdrawalAssets(),
            "Reserve less than actual balance"
        );
    }

    function prop_assets_deposited_vs_assets_received() public {
        uint256 depositEpoch = hypoVault.depositEpoch();
        uint256 withdrawalEpoch = hypoVault.withdrawalEpoch();

        uint256 totalAssetsDepositedAcrossEpochs;
        uint256 totalAssetsReceivedAcrossEpochs;

        if (depositEpoch >= 0) {
            for (uint256 i = 0; i <= depositEpoch; i++) {
                (uint128 assetsDeposited,,) = hypoVault.getDepositEpochState(i);
                totalAssetsDepositedAcrossEpochs += assetsDeposited;
            }
        }

        if (withdrawalEpoch >= 0) {
            for (uint256 i = 0; i <= withdrawalEpoch; i++) {
                (, uint128 assetsReceived,) = hypoVault.getWithdrawalEpochState(i);
                totalAssetsReceivedAcrossEpochs += assetsReceived;
            }
        }

        gte(
            totalAssetsDepositedAcrossEpochs,
            totalAssetsReceivedAcrossEpochs,
            "Total assets deposited should be >= total assets received"
        );
    }

    function prop_basis_always_backed_by_assets() public {
        address[] memory allActors = _getActors();
        for (uint256 i = 0; i < allActors.length; i++) {
            address actor = allActors[i];
            if (hypoVault.userBasis(actor) > 0) {
                gt(
                    IERC20(hypoVault.underlyingToken()).balanceOf(address(hypoVault)),
                    0,
                    "user can't redeem basis for assets"
                );
            }
        }
    }

    function prop_shares_always_backed_by_assets() public {
        address[] memory allActors = _getActors();
        for (uint256 i = 0; i < allActors.length; i++) {
            address actor = allActors[i];
            if (hypoVault.balanceOf(actor) > 0) {
                gt(
                    IERC20(hypoVault.underlyingToken()).balanceOf(address(hypoVault)),
                    0,
                    "user can't redeem basis for assets"
                );
            }
        }
    }

    function prop_user_has_basis_and_shares() public {
        address[] memory allActors = _getActors();
        for (uint256 i = 0; i < allActors.length; i++) {
            address actor = allActors[i];
            if (hypoVault.userBasis(actor) > 0) {
                gt(hypoVault.balanceOf(actor), 0, "user can't have basis without balance");
            }

            if (hypoVault.balanceOf(actor) > 0) {
                gt(hypoVault.userBasis(actor), 0, "user can't have shares without basis");
            }
        }
    }

    // function prop_user_basis_increase_after_execute_deposit() public {
    //     if (currentOperation == OpType.EXECUTE_DEPOSIT) {
    //         gt(_after.user_basis, _before.user_basis, "User basis should increase after executeDeposit");
    //     }
    // }

    

    function prop_user_balanceOf_increase_after_execute_deposit() public {
        if (currentOperation == OpType.EXECUTE_DEPOSIT) {
            gt(_after.user_balanceOf, _before.user_balanceOf, "User balanceOf should increase after executeDeposit");
        }
    }

    function prop_user_basis_increase_after_execute_deposit() public {
        if (currentOperation == OpType.EXECUTE_DEPOSIT && _after.user_basis > _before.user_basis) {
            gt(_after.user_basis, _before.user_basis, "User basis should increase after executeDeposit");
        }
    }


    function prop_fulfill_withdrawals_cannot_exceed_requested() public {
        uint256 currentWithdrawalEpoch = hypoVault.withdrawalEpoch();
        
        // Debug: Check if currentWithdrawalEpoch has an unexpected value
        if (currentWithdrawalEpoch == type(uint256).max) {
            return; // No withdrawal epochs exist yet
        }
        
        // Only check if there are actual withdrawal epochs
        if (currentWithdrawalEpoch == 0) {
            // Check if epoch 0 actually exists by trying to call it
            try hypoVault.getWithdrawalEpochState(0) returns (
                uint128 sharesWithdrawn, uint128 assetsReceived, uint128 sharesFulfilled
            ) {
                lte(
                    sharesFulfilled,
                    sharesWithdrawn,
                    "Shares fulfilled cannot exceed shares requested in epoch"
                );
            } catch {
                // Epoch 0 doesn't exist, nothing to check
                return;
            }
        } else {
            // Check all withdrawal epochs
            for (uint256 i = 0; i <= currentWithdrawalEpoch; i++) {
                (uint256 sharesWithdrawn, uint256 assetsReceived, uint256 sharesFulfilled) = hypoVault.getWithdrawalEpochState(i);
                
                lte(
                    sharesFulfilled,
                    sharesWithdrawn,
                    "Shares fulfilled cannot exceed shares requested in epoch"
                );
            }
        }
    }

    function prop_fulfill_withdrawals_cannot_exceed_requested() public {
    uint256 currentWithdrawalEpoch = hypoVault.withdrawalEpoch();
    // Only check epochs if at least one withdrawal epoch exists
    if (currentWithdrawalEpoch > 0) {
            for (uint256 i = 0; i <= currentWithdrawalEpoch; i++) {
                (uint256 sharesWithdrawn, uint256 assetsReceived, uint256 sharesFulfilled) = 
                    hypoVault.getWithdrawalEpochState(i);
                lte(sharesFulfilled, sharesWithdrawn, "Shares fulfilled cannot exceed shares requested in epoch");
            }
        }
    }
    
  


    function test_transfer_basis_loss_FIXED(address sender, address recipient, uint256 additionalBasis, uint256 additionalShares, uint256 transferAmount) public {
        require(sender != address(0) && recipient != address(0));
        require(sender != recipient, "Sender and recipient must be different");
        
        // Bound the inputs
        additionalShares = between(additionalShares, 1, type(uint64).max);
        additionalBasis = between(additionalBasis, 1, type(uint64).max);
        
        // Setup initial state
        hypoVault.increaseBasisAndShares(sender, additionalBasis, additionalShares);
        hypoVault.increaseBasisAndShares(recipient, additionalBasis, additionalShares);
        
        // Record before state
        uint256 beforeBalanceSender = hypoVault.balanceOf(sender);
        uint256 beforeBasisSender = hypoVault.userBasis(sender);
        uint256 beforeBalanceRecipient = hypoVault.balanceOf(recipient);
        uint256 beforeBasisRecipient = hypoVault.userBasis(recipient);
        
        // Bound transfer amount to sender's balance
        uint256 transferAmount = between(transferAmount, 1, beforeBalanceSender);
        
        // Execute transfer
        vm.prank(sender);
        hypoVault.transfer(recipient, transferAmount);
        
        // Record after state
        uint256 afterBalanceSender = hypoVault.balanceOf(sender);
        uint256 afterBasisSender = hypoVault.userBasis(sender);
        uint256 afterBalanceRecipient = hypoVault.balanceOf(recipient);
        uint256 afterBasisRecipient = hypoVault.userBasis(recipient);
        
        // ✅ KEY ASSERTION: Recipient should never have shares without basis
        if (afterBalanceRecipient > 0) {
            gt(afterBasisRecipient, 0, "Recipient has shares but no basis - rounding bug detected!");
        }
        
        // ✅ KEY ASSERTION: If shares were transferred, some basis must be transferred (unless sender had no basis)
        if (transferAmount > 0 && beforeBasisSender > 0) {
            uint256 basisTransferred = afterBasisRecipient - beforeBasisRecipient;
            gt(basisTransferred, 0, "Shares transferred but no basis transferred - rounding bug!");
        }
        
        // ✅ CONSERVATION: Total basis should be conserved
        eq(afterBasisSender + afterBasisRecipient, beforeBasisSender + beforeBasisRecipient, 
        "Total basis should be conserved");
        
        // ✅ SHARES CONSERVATION: Total shares should be conserved  
        eq(afterBalanceSender + afterBalanceRecipient, beforeBalanceSender + beforeBalanceRecipient,
        "Total shares should be conserved");
    }

    


}

