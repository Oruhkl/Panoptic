// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "../BeforeAfter.sol";
import {Properties} from "../Properties.sol";
// Chimera deps
import {vm} from "@chimera/Hevm.sol";

// Helpers
import {Panic} from "@recon/Panic.sol";

import "src/HypoVault.sol";

abstract contract HypoVaultTargets is BaseTargetFunctions, Properties {
    /// CUSTOM TARGET FUNCTIONS - Add your own target functions here ///

    function hypoVault_fulfillDeposits_clamped(uint256 assetsToFulfill, bytes memory managerInput) public asManager {
        (uint128 assetsDeposited,,) = hypoVault.getDepositEpochState(hypoVault.depositEpoch());
        if (assetsDeposited == 0) {
            uint256 assetsToDeposit;
            assetsToDeposit = between(assetsToDeposit, 1, type(uint64).max);

            hypoVault.requestDeposit(uint128(assetsToDeposit));
            uint256 nav;
            nav = between(nav, 1, assetsToDeposit);
            vaultAccountantMock.setNav(nav);
        }
        (assetsDeposited,,) = hypoVault.getDepositEpochState(hypoVault.depositEpoch());
        assetsToFulfill = between(assetsToFulfill, 1, assetsDeposited);
        managerInput = vaultAccountantMock.expectedManagerInput();
        hypoVault.fulfillDeposits(assetsToFulfill, managerInput);
    }

    function hypoVault_executeDeposit_clamped(uint256 epoch)
        public
        updateGhostsWithType(OpType.EXECUTE_DEPOSIT)
        asActor
    {
        require(epoch < hypoVault.depositEpoch());
        hypoVault.executeDeposit(_getActor(), epoch);
    }

    function hypoVault_executeWithdrawal_clamped(address user, uint256 epoch) public {
        uint256 currentEpoch = hypoVault.depositEpoch();
        uint256 assets;
        assets = between(assets, 1e10, type(uint64).max);
        hypoVault.requestDeposit(uint128(assets));

        uint256 assetsToFulfill;
        bytes memory managerInput;
        _hypoVault_fulfillDeposits_internal(assetsToFulfill, managerInput);

        hypoVault.executeDeposit(address(this), currentEpoch);

        uint256 sharesToFulfill;
        require(hypoVault.balanceOf(address(this)) > 0);
        uint256 sharesToWithdraw;
        sharesToWithdraw =
            between(sharesToWithdraw, hypoVault.balanceOf(address(this)) / 3, hypoVault.balanceOf(address(this)));

        hypoVault.requestWithdrawal(uint128(sharesToWithdraw));
        managerInput = vaultAccountantMock.expectedManagerInput();

        (uint128 sharesWithdrawn, uint128 assetsReceived, uint128 sharesFulfilled) =
            hypoVault.getWithdrawalEpochState(hypoVault.withdrawalEpoch());
        (uint128 assetsDeposited,,) = hypoVault.getDepositEpochState(hypoVault.depositEpoch());

        uint256 totalAssets = vaultAccountantMock.nav() + 1 - assetsDeposited - hypoVault.reservedWithdrawalAssets();

        sharesToFulfill = between(sharesToFulfill, sharesWithdrawn / 6, sharesWithdrawn / 3);
        uint256 maxAssetsReceived = (sharesToFulfill * totalAssets) / hypoVault.totalSupply();

        uint256 currentWithdrawalEpoch = hypoVault.withdrawalEpoch();

        vm.prank(Manager);
        hypoVault.fulfillWithdrawals(sharesToFulfill, maxAssetsReceived, managerInput);

        hypoVault.executeWithdrawal(address(this), currentWithdrawalEpoch);
    }

    function hypoVault_requestWithdrawal_clamped(uint128 shares) public {
        uint256 currentEpoch = hypoVault.depositEpoch();
        uint256 assets;
        assets = between(assets, 1e10, type(uint64).max);
        hypoVault.requestDeposit(uint128(assets));

        uint256 assetsToFulfill;
        bytes memory managerInput;
        _hypoVault_fulfillDeposits_internal(assetsToFulfill, managerInput);

        hypoVault.executeDeposit(address(this), currentEpoch);

        require(hypoVault.balanceOf(address(this)) > 0);
        uint256 sharesToWithdraw = between(uint256(shares), 1, hypoVault.balanceOf(address(this)));

        hypoVault.requestWithdrawal(uint128(sharesToWithdraw));
    }

    function hypoVault_fulfillWithdrawals_clamped(
        uint256 sharesToFulfill,
        uint256 maxAssetsReceived,
        bytes memory managerInput
    ) public {
        uint256 currentEpoch = hypoVault.depositEpoch();
        uint256 assets;
        assets = between(assets, 1e10, type(uint64).max);
        hypoVault.requestDeposit(uint128(assets));

        uint256 assetsToFulfill;
        _hypoVault_fulfillDeposits_internal(assetsToFulfill, managerInput);

        hypoVault.executeDeposit(address(this), currentEpoch);

        require(hypoVault.balanceOf(address(this)) > 0);
        uint256 sharesToWithdraw = between(sharesToFulfill, 1, hypoVault.balanceOf(address(this)));

        hypoVault.requestWithdrawal(uint128(sharesToWithdraw));
        managerInput = vaultAccountantMock.expectedManagerInput();

        (uint128 sharesWithdrawn, uint128 assetsReceived, uint128 sharesFulfilled) =
            hypoVault.getWithdrawalEpochState(hypoVault.withdrawalEpoch());
        (uint128 assetsDeposited,,) = hypoVault.getDepositEpochState(hypoVault.depositEpoch());

        uint256 totalAssets = vaultAccountantMock.nav() + 1 - assetsDeposited - hypoVault.reservedWithdrawalAssets();

        sharesToFulfill = between(sharesToFulfill, sharesWithdrawn / 6, sharesWithdrawn / 3);
        maxAssetsReceived = (sharesToFulfill * totalAssets) / hypoVault.totalSupply();

        vm.prank(Manager);
        hypoVault.fulfillWithdrawals(sharesToFulfill, maxAssetsReceived, managerInput);
    }

    function hypoVault_transfer_clamped(address to, uint256 amount) public {
        address currentActor = _getActor();
        uint256 currentEpoch = hypoVault.depositEpoch();
        uint256 assets;
        assets = between(assets, 1e10, type(uint64).max);
        vm.prank(currentActor);
        hypoVault.requestDeposit(uint128(assets));

        uint256 assetsToFulfill;
        bytes memory managerInput;
        _hypoVault_fulfillDeposits_internal(assetsToFulfill, managerInput);

        hypoVault.executeDeposit(_getActor(), currentEpoch);
        amount = between(amount, 0, hypoVault.userBasis(_getActor()));
        vm.prank(currentActor);
        hypoVault.transfer(to, amount);
    }

    /// AUTO GENERATED TARGET FUNCTIONS - WARNING: DO NOT DELETE OR MODIFY THIS LINE ///

    function hypoVault_approve(address spender, uint256 amount) public asActor {
        hypoVault.approve(spender, amount);
    }

    function hypoVault_cancelDeposit(address depositor) public asManager {
        hypoVault.cancelDeposit(depositor);
    }

    function hypoVault_cancelWithdrawal(address withdrawer) public asManager {
        hypoVault.cancelWithdrawal(withdrawer);
    }

    function hypoVault_executeDeposit(address user, uint256 epoch) public asActor {
        hypoVault.executeDeposit(user, epoch);
    }

    function hypoVault_executeDeposit_gh(uint256 epoch) public updateGhostsWithType(OpType.EXECUTE_DEPOSIT) asActor {
        hypoVault.executeDeposit(_getActor(), epoch);
    }

    function hypoVault_executeWithdrawal(address user, uint256 epoch) public asActor {
        hypoVault.executeWithdrawal(user, epoch);
    }

    function hypoVault_fulfillDeposits(uint256 assetsToFulfill, bytes memory managerInput) public asManager {
        hypoVault.fulfillDeposits(assetsToFulfill, managerInput);

        // try hypoVault.fulfillDeposits(assetsToFulfill, managerInput) {}
        // catch {
        //     t(false, "hypoVault_fulfillDeposits");
        // }
    }

    function hypoVault_fulfillWithdrawals(uint256 sharesToFulfill, uint256 maxAssetsReceived, bytes memory managerInput)
        public
        asManager
    {
        hypoVault.fulfillWithdrawals(sharesToFulfill, maxAssetsReceived, managerInput);
    }

    function hypoVault_manage(address[] memory targets, bytes[] memory data, uint256[] memory values) public asActor {
        hypoVault.manage(targets, data, values);
    }

    function hypoVault_manage(address target, bytes memory data, uint256 value) public asActor {
        hypoVault.manage(target, data, value);
    }

    function hypoVault_multicall(bytes[] memory data) public asActor {
        hypoVault.multicall(data);
    }

    function hypoVault_renounceOwnership() public asActor {
        hypoVault.renounceOwnership();
    }

    function hypoVault_requestDeposit(uint128 assets) public asActor {
        hypoVault.requestDeposit(assets);
    }

    function hypoVault_requestWithdrawal(uint128 shares) public asActor {
        hypoVault.requestWithdrawal(shares);
    }

    function _hypoVault_fulfillDeposits_internal(uint256 assetsToFulfill, bytes memory managerInput) internal {
        vm.startPrank(Manager);
        (uint128 assetsDeposited,,) = hypoVault.getDepositEpochState(hypoVault.depositEpoch());
        uint256 nav;
        nav = between(nav, assetsDeposited, type(uint64).max);
        vaultAccountantMock.setNav(nav);
        assetsToFulfill = between(assetsToFulfill, assetsDeposited / 2, assetsDeposited);
        managerInput = vaultAccountantMock.expectedManagerInput();
        hypoVault.fulfillDeposits(assetsToFulfill, managerInput);
        vm.stopPrank();
    }

    // function hypoVault_setAccountant(IVaultAccountant _accountant) public asActor {
    //     hypoVault.setAccountant(_accountant);
    // }

    // function hypoVault_setFeeWallet(address _feeWallet) public asActor {
    //     hypoVault.setFeeWallet(_feeWallet);
    // }

    // function hypoVault_setManager(address _manager) public asActor {
    //     hypoVault.setManager(_manager);
    // }

    function hypoVault_transfer(address to, uint256 amount) public asActor {
        hypoVault.transfer(to, amount);
    }

    function hypoVault_transferFrom(address from, address to, uint256 amount) public asActor {
        hypoVault.transferFrom(from, to, amount);
    }

    // function hypoVault_transferOwnership(address newOwner) public asActor {
    //     hypoVault.transferOwnership(newOwner);
    // }

    function anyActor(uint256 actorNum) public {
        actorNum = between(actorNum, 0, _getActors().length);
        _switchActor(actorNum);
    }
}
