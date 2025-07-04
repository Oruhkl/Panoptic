// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

// Chimera deps
import {BaseSetup} from "@chimera/BaseSetup.sol";
import {vm} from "@chimera/Hevm.sol";

// Managers
import {ActorManager} from "@recon/ActorManager.sol";
import {AssetManager} from "@recon/AssetManager.sol";

// Helpers
import {Utils} from "@recon/Utils.sol";
import "forge-std/console2.sol";

// Your deps
import "src/HypoVault.sol";
import "src/Token.sol";
import "./mocks/VaultAccountantMock.sol";
import "src/interfaces/IVaultAccountant.sol";
import "lib/panoptic-v1.1/lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {MockERC20} from "@recon/MockERC20.sol";

abstract contract Setup is BaseSetup, ActorManager, AssetManager, Utils {
    HypoVault hypoVault;
    IERC20 token;
    address FeeWallet = address(0x5678);
    VaultAccountantMock vaultAccountantMock;
    address Manager = address(0x1234);

    /// === Setup === ///
    /// This contains all calls to be performed in the tester constructor, both for Echidna and Foundry
    function setup() internal virtual override {
        vaultAccountantMock = new VaultAccountantMock();
        address nToken = _newAsset(18);
        token = IERC20(nToken);
        hypoVault = new HypoVault(address(token), Manager, IVaultAccountant(address(vaultAccountantMock)), 100); // 1% performance fee

        vaultAccountantMock.setExpectedVault(address(hypoVault));
        hypoVault.setFeeWallet(FeeWallet);

        for (uint256 i = 1; i <= 300; i++) {
            address actor = address(uint160(i * 1000));

            MockERC20(address(token)).mint(actor, type(uint64).max);
            _addActor(actor);

            vm.prank(actor);
            token.approve(address(hypoVault), type(uint64).max);
        }
        MockERC20(address(token)).mint(Manager, type(uint64).max);
        vm.prank(Manager);
        token.approve(address(hypoVault), type(uint64).max);

        MockERC20(address(token)).mint(address(this), type(uint64).max);
        token.approve(address(hypoVault), type(uint64).max);
    }

    /// === MODIFIERS === ///
    /// Prank admin and actor

    modifier asAdmin() {
        vm.prank(address(this));
        _;
    }

    modifier asActor() {
        vm.startPrank(address(_getActor()));
        _;
        vm.stopPrank();
    }

    modifier asManager() {
        vm.startPrank(Manager);
        _;
        vm.stopPrank();
    }

    function betweenC(uint256 value, uint256 low, uint256 high) internal virtual returns (uint256) {
        if (value < low || value > high) {
            uint256 ans = low + (value % (high - low + 1));
            return ans;
        }
        return value;
    }

    modifier asActorEntropy(uint256 entropy) {
        entropy = betweenC(entropy, 1, _getActors().length + 1);
        _switchActor(entropy);
        console2.log("Actor switched to:", _getActor());
        vm.startPrank(_getActor());
        _;
        vm.stopPrank();
    }

    modifier stateless() {
        _;
        revert("stateless");
    }
}
