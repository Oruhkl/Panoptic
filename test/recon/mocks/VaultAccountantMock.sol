// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

contract VaultAccountantMock {
    uint256 public nav;
    address public expectedVault;
    bytes public expectedManagerInput;

    function setNav(uint256 _nav) external {
        nav = _nav;
    }

    function setExpectedVault(address _expectedVault) external {
        expectedVault = _expectedVault;
    }

    function setExpectedManagerInput(bytes memory _expectedManagerInput) external {
        expectedManagerInput = _expectedManagerInput;
    }

    function computeNAV(address vault, address, bytes memory managerInput) external view returns (uint256) {
        require(vault == expectedVault, "Invalid vault");
        if (managerInput.length > 0) {
            require(keccak256(managerInput) == keccak256(expectedManagerInput), "Invalid manager input");
        }
        return nav;
    }
}
