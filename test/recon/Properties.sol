// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

abstract contract Properties is BeforeAfter, Asserts {
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

    // function prop_user_has_basis_and_shares() public {
    //     address[] memory allActors = _getActors();
    //     for (uint256 i = 0; i < allActors.length; i++) {
    //         address actor = allActors[i];
    //         if (hypoVault.userBasis(actor) > 0) {
    //             gt(hypoVault.balanceOf(actor), 0, "user can't have basis without balance");
    //         }

    //         if (hypoVault.balanceOf(actor) > 0) {
    //             gt(hypoVault.userBasis(actor), 0, "user can't have shares without basis");
    //         }
    //     }
    // }

    function prop_user_basis_increase_after_execute_deposit() public {
        if (currentOperation == OpType.EXECUTE_DEPOSIT) {
            gt(_after.user_basis, _before.user_basis, "User basis should increase after executeDeposit");
        }
    }

    function prop_user_balanceOf_increase_after_execute_deposit() public {
        if (currentOperation == OpType.EXECUTE_DEPOSIT) {
            gt(_after.user_balanceOf, _before.user_balanceOf, "User balanceOf should increase after executeDeposit");
        }
    }
}
