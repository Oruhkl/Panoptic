// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {FoundryAsserts} from "@chimera/FoundryAsserts.sol";

import "forge-std/console2.sol";

import {Test} from "forge-std/Test.sol";
import {TargetFunctions} from "./TargetFunctions.sol";

// forge test --match-contract CryticToFoundry -vv
contract CryticToFoundry is Test, TargetFunctions, FoundryAsserts {
    function setUp() public {
        setup();
    }

    // forge test --match-test test_crytic -vvv
    function test_crytic() public {
        // TODO: add failing property tests here for debugging
    }

    // // forge test --match-test test_prop_user_has_basis_and_shares_84gk -vvv
    // function test_prop_user_has_basis_and_shares_84gk() public {

    //     anyActor(1);

    //     hypoVault_transfer_clamped(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496,1);

    //     prop_user_has_basis_and_shares();

    // }

    // forge test --match-test test_prop_user_basis_increase_after_execute_deposit_93sk -vvv

    function test_prop_user_basis_increase_after_execute_deposit_93sk() public {
        vm.roll(55944);
        vm.warp(360664);
        hypoVault_transfer_clamped(
            0x2a07706473244BC757E10F2a9E86fB532828afe3,
            39397840983553115406040529638625124915128992348275767817182411850403882792108
        );

        vm.roll(55944);
        vm.warp(360664);
        hypoVault_executeDeposit_clamped(0);

        vm.roll(55947);
        vm.warp(405379);
        prop_user_basis_increase_after_execute_deposit();
    }

    // forge test --match-test test_prop_user_balanceOf_increase_after_execute_deposit_6q04 -vvv

    function test_prop_user_balanceOf_increase_after_execute_deposit_6q04() public {
        vm.roll(522);
        vm.warp(490923);
        hypoVault_fulfillDeposits_clamped(
            7237005577332262192875851039452150917064135354646507710533019595135224972144,
            hex"00000000006c00000000000000206e00007100006e000000000020610000000000006c00007400617300000000"
        );

        vm.roll(530);
        vm.warp(490983);
        hypoVault_executeDeposit_clamped(0);

        vm.roll(555);
        vm.warp(850947);
        prop_user_balanceOf_increase_after_execute_deposit();
    }
}
