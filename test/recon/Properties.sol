// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Asserts} from "@chimera/Asserts.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

abstract contract Properties is BeforeAfter, Asserts {
    // function prop_total_assets_never_return_zero_when_vault_holds_assets() public {
    //     bytes memory expectedManagerInput = vaultAccountantMock.expectedManagerInput();
    //     uint256 nav =
    //         vaultAccountantMock.computeNAV(address(hypoVault), hypoVault.underlyingToken(), expectedManagerInput);
    //     (uint128 assetsDeposited,,) = hypoVault.getDepositEpochState(hypoVault.depositEpoch());
    //     uint256 reserved = hypoVault.reservedWithdrawalAssets();
    //     uint256 totalAssets = nav + 1 - assetsDeposited - reserved;

    //     if (nav > 0) {
    //         // Vault holds assets if NAV is positive
    //         gt(totalAssets, 0, "totalAssets should never return zero when vault holds assets");
    //     }
    // }

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

    function prop_shares_always_backed_by_assets() public {
        address[] memory allActors = _getActors();
        for (uint256 i = 0; i < allActors.length; i++) {
            if (hypoVault.userBasis(allActors[i]) > 0) {
                gt(
                    IERC20(hypoVault.underlyingToken()).balanceOf(address(hypoVault)),
                    0,
                    "user can't redeem basis for assets"
                );
            }
        }
    }
}
