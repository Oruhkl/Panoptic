// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {Setup} from "./Setup.sol";

// ghost variables for tracking state variable values before and after function calls
abstract contract BeforeAfter is Setup {
    enum OpType {
        GENERIC,
        REQUEST_DEPOSIT,
        REQUEST_WITHDRAWAL,
        EXECUTE_DEPOSIT,
        EXECUTE_WITHDRAWAL,
        FULFILL_DEPOSITS,
        FULFILL_WITHDRAWALS
    }

    OpType internal currentOperation;

    struct Vars {
        uint256 user_basis;
        uint256 user_balanceOf;
    }

    Vars internal _before;
    Vars internal _after;

    modifier updateGhostsWithType(OpType op) {
        currentOperation = op;
        __before();
        _;
        __after();
    }

    modifier updateGhosts() {
        __before();
        _;
        __after();
    }

    function __before() internal {
        _before.user_basis = hypoVault.userBasis(_getActor());
        _before.user_balanceOf = hypoVault.balanceOf(_getActor());
    }

    function __after() internal {
        _after.user_basis = hypoVault.userBasis(_getActor());
        _after.user_balanceOf = hypoVault.balanceOf(_getActor());
    }
}
