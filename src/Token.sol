// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {ERC20S} from "lib/panoptic-v1.1/test/foundry/testUtils/ERC20S.sol";

contract Token is ERC20S {
    constructor(string memory _name, string memory _symbol, uint8 _decimals) ERC20S(_name, _symbol, _decimals) {}
}
