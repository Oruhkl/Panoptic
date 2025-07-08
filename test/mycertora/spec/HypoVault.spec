using VaultAccountantMock as accountant;
using Token as underlyingToken;

methods {
    function depositEpoch() external returns (uint128) envfree;
    function withdrawalEpoch() external returns (uint128) envfree;
    function userBasis(address user) external returns (uint256) envfree;
    function queuedDeposit(address user, uint256 epoch) external returns (uint128) envfree;
    function getDepositEpochState(uint256 epoch) external returns (uint128, uint128, uint128) envfree;
    function getWithdrawalEpochState(uint256 epoch) external returns (uint128, uint128, uint128) envfree;
    function balanceOf(address user) external returns (uint256) envfree;
    function underlyingToken.balanceOf(address) external returns(uint256) envfree;
    function totalSupply() external returns(uint256) envfree;
    function reservedWithdrawalAssets() external returns(uint256) envfree;
    function manager() external returns(address) envfree;
    function balanceOf(address user) external returns (uint256) envfree;
    function userBasis(address user) external returns (uint256) envfree;
    
}

definition MAX_UINT128() returns uint128 = 0xffffffffffffffffffffffffffffffff;
definition MAX_UINT64() returns uint64 = 0xffffffffffffffff;
// Helper function to check if an epoch is current
function isCurrentDepositEpoch(uint256 epoch) returns bool {
    return epoch == currentContract.depositEpoch();
}

function isCurrentWithdrawalEpoch(uint256 epoch) returns bool {
    return epoch == currentContract.withdrawalEpoch();
}

function isManager(env e) returns bool{
    return currentContract.manager() == e.msg.sender;
}




// // Rule 1: Deposits and withdrawals made in the current epoch cannot be executed until the manager fulfills and advances the epoch
// rule cannotExecuteCurrentEpochDeposits(address user) {
//     env e;

//     uint256 currentEpoch = currentContract.depositEpoch();
    
//     // Ensure user has a queued deposit in current epoch
//     require currentContract.queuedDeposit(user, currentEpoch) > 0;
    
//     // Get current epoch state
//     uint128 assetsDeposited;
//     uint128 sharesReceived;
//     uint128 assetsFulfilled;
//     assetsDeposited, sharesReceived, assetsFulfilled = currentContract.getDepositEpochState(currentEpoch);
    
//     // If epoch is not fully fulfilled, execution should fail
//     require assetsFulfilled < assetsDeposited;
    
//     currentContract.executeDeposit@withrevert(e, user, currentEpoch);
//     assert lastReverted, "Should not be able to execute deposit in unfulfilled current epoch";
// }

// rule cannotExecuteCurrentEpochWithdrawals(address user) {
//     env e;
//     uint256 currentEpoch = currentContract.withdrawalEpoch();
    
//     // Ensure user has a queued withdrawal in current epoch
//     require currentContract.queuedWithdrawal(user, currentEpoch) > 0;
    
//     // Get current epoch state
//     uint128 sharesWithdrawn;
//     uint128 assetsReceived;
//     uint128 sharesFulfilled;
//     sharesWithdrawn, assetsReceived, sharesFulfilled = currentContract.getWithdrawalEpochState(currentEpoch);
    
//     // If epoch is not fully fulfilled, execution should fail
//     require sharesFulfilled < sharesWithdrawn;
    
//     currentContract.executeWithdrawal@withrevert(e, user, currentEpoch);
//     assert lastReverted, "Should not be able to execute withdrawal in unfulfilled current epoch";
// }

// Rule 2: Only deposits/withdrawals in the current epoch can be cancelled
// rule canOnlyCancelCurrentEpochDeposits(address user) {
//     env e;
//     uint256 currentEpoch = currentContract.depositEpoch();
    
//     // Store initial state
//     uint128 queuedDepositBefore = currentContract.queuedDeposit(user, currentEpoch);
    
//     // Ensure user has a deposit to cancel
//     require queuedDepositBefore > 0;
    
//     currentContract.cancelDeposit(e, user);
    
//     // After cancellation, queued deposit should be zero
//     uint128 queuedDepositAfter = currentContract.queuedDeposit(user, currentEpoch);
//     assert queuedDepositAfter == 0, "Queued deposit should be cancelled";
// }

// rule canOnlyCancelCurrentEpochWithdrawals(address user) {
//     env e;
//     uint256 currentEpoch = currentContract.withdrawalEpoch();
    
//     // Store initial state
//     uint128 queuedWithdrawalBefore = currentContract.queuedWithdrawal(user, currentEpoch);
    
//     // Ensure user has a withdrawal to cancel
//     require queuedWithdrawalBefore > 0;
    
//     currentContract.cancelWithdrawal(e, user);
    
//     // After cancellation, queued withdrawal should be zero
//     uint128 queuedWithdrawalAfter = currentContract.queuedWithdrawal(user, currentEpoch);
//     assert queuedWithdrawalAfter == 0, "Queued withdrawal should be cancelled";
// }

// // Rule 3: Only the manager can cancel or fulfill deposits/withdrawals
// rule onlyManagerCanFulfillDeposits(uint256 assetsToFulfill, bytes managerInput) {
//     env e;
//     require !isManager(e);
    
//     currentContract.fulfillDeposits@withrevert(e, assetsToFulfill, managerInput);
//     assert lastReverted, "Only manager should be able to fulfill deposits";
// }

// rule onlyManagerCanFulfillWithdrawals(uint128 sharesToFulfill, uint256 maxAssetsReceived, bytes managerInput) {
//     env e;
//     require !isManager(e);
    
//     currentContract.fulfillWithdrawals@withrevert(e, sharesToFulfill, maxAssetsReceived, managerInput);
//     assert lastReverted, "Only manager should be able to fulfill withdrawals";
// }

// rule onlyManagerCanCancelDeposits(address user) {
//     env e;
//     require !isManager(e);
//     require e.msg.sender != user; // User can cancel their own deposits
    
//     currentContract.cancelDeposit@withrevert(e, user);
//     assert lastReverted, "Only manager or user should be able to cancel deposits";
// }

// rule onlyManagerCanCancelWithdrawals(address user) {
//     env e;
//     require !isManager(e);
//     require e.msg.sender != user; // User can cancel their own withdrawals
    
//     currentContract.cancelWithdrawal@withrevert(e, user);
//     assert lastReverted, "Only manager or user should be able to cancel withdrawals";
// }

// // Rule 4: User fulfillment proportional to their contribution
// rule userDepositFulfillmentProportional(address user, uint256 epoch) {
//     env e;
    
//     // Get epoch state
//     uint128 assetsDeposited;
//     uint128 sharesReceived;
//     uint128 assetsFulfilled;
//     assetsDeposited, sharesReceived, assetsFulfilled = currentContract.getDepositEpochState(epoch);
    
//     // Get user's queued deposit
//     uint128 userDeposit = currentContract.queuedDeposit(user, epoch);
    
//     // Ensure meaningful values
//     require assetsDeposited > 0 && userDeposit > 0;
//     require assetsFulfilled <= assetsDeposited;
    
//     // Calculate expected user fulfillment
//     mathint expectedUserFulfillment = (to_mathint(userDeposit) * to_mathint(assetsFulfilled)) / to_mathint(assetsDeposited);
    
//     // Execute deposit
//     currentContract.executeDeposit(e, user, epoch);
    
//     // User should receive shares proportional to their deposit
//     // This is a simplified check - actual implementation may vary
//     assert expectedUserFulfillment <= to_mathint(userDeposit), "User fulfillment should not exceed their deposit";
// }

// rule userWithdrawalFulfillmentProportional(address user, uint256 epoch) {
//     env e;
    
//     // Get epoch state
//     uint128 sharesWithdrawn;
//     uint128 assetsReceived;
//     uint128 sharesFulfilled;
//     sharesWithdrawn, assetsReceived, sharesFulfilled = currentContract.getWithdrawalEpochState(epoch);
    
//     // Get user's queued withdrawal
//     uint128 userWithdrawal = currentContract.queuedWithdrawal(user, epoch);
    
//     // Ensure meaningful values
//     require sharesWithdrawn > 0 && userWithdrawal > 0;
//     require sharesFulfilled <= sharesWithdrawn;
    
//     // Calculate expected user fulfillment
//     mathint expectedUserFulfillment = (to_mathint(userWithdrawal) * to_mathint(sharesFulfilled)) / to_mathint(sharesWithdrawn);
    
//     // Execute withdrawal
//     currentContract.executeWithdrawal(e, user, epoch);
    
//     // User should receive assets proportional to their withdrawal
//     assert expectedUserFulfillment <= to_mathint(userWithdrawal), "User fulfillment should not exceed their withdrawal";
// }

// // Rule 5: The fulfilled amount cannot exceed the deposited/withdrawn amount for a given epoch
// rule fulfilledDepositCannotExceedTotal(uint256 epoch) {
//     env e;
//     method f;
//     calldataarg args;
//     uint128 assetsDeposited;
//     uint128 sharesReceived;
//     uint128 assetsFulfilled;
//     assetsDeposited, sharesReceived, assetsFulfilled = currentContract.getDepositEpochState(epoch);
//     require assetsFulfilled <= assetsDeposited;

//     f(e, args);
    
//     assert assetsFulfilled <= assetsDeposited, "Fulfilled deposits cannot exceed total deposits";
// }

// rule fulfilledWithdrawalCannotExceedTotal(uint256 epoch) {
//     env e;
//     method f;
//     calldataarg args;
//     uint128 sharesWithdrawn;
//     uint128 assetsReceived;
//     uint128 sharesFulfilled;
//     uint128 assetsFulfilled;
//     uint128 assetsDeposited;
//     sharesWithdrawn, assetsReceived, sharesFulfilled = currentContract.getWithdrawalEpochState(epoch);
//     require sharesFulfilled <= sharesWithdrawn;
//     f(e, args);
    
//     assert sharesFulfilled <= sharesWithdrawn, "Fulfilled withdrawals cannot exceed total withdrawals";
// }

// // Existing rule with improved assertion message
// rule assetRecievedCannotBeMoreThanmaxAssetsReceived(){
//     env e;
//     require e.msg.sender != currentContract;
//     uint128 sharesWithdrawn;
//     uint128 assetsReceived;
//     uint128 sharesToFulfill;
//     uint256 maxAssetsReceived;
//     bytes managerInput;
//     require maxAssetsReceived < MAX_UINT128() && sharesToFulfill < MAX_UINT128();
    
//     currentContract.fulfillWithdrawals(e, sharesToFulfill, maxAssetsReceived, managerInput);
//     require currentContract.withdrawalEpoch() < MAX_UINT128();
//     sharesWithdrawn, assetsReceived, sharesToFulfill = currentContract.getWithdrawalEpochState(currentContract.withdrawalEpoch());
    
//     // Ensure the assets received do not exceed the maximum allowed
//     assert assetsReceived <= maxAssetsReceived, "Assets received exceed the maximum allowed";
// }

// invariant epochsNeverDecrease(uint128 depositEpochBefore, uint128 withdrawalEpochBefore)
//     currentContract.depositEpoch() >= depositEpochBefore &&
//     currentContract.withdrawalEpoch() >= withdrawalEpochBefore
//     {
//         preserved with (env e) {
//             require e.msg.sender != currentContract;
//             require depositEpochBefore == currentContract.depositEpoch();
//             require withdrawalEpochBefore == currentContract.withdrawalEpoch();
//         }
//     }



// function getAssetDepositedInCurrentEpouch() returns uint128 {
//     uint128 assetsDeposited;
//     uint128 sharesReceived;
//     uint128 assetsFulfilled;
//     require currentContract.depositEpoch() < MAX_UINT128();
//     (assetsDeposited, sharesReceived, assetsFulfilled) = currentContract.getDepositEpochState(currentContract.depositEpoch());
//     return assetsDeposited;
// }

// function getassetsFulfilledInCurrentEpouch() returns uint128 {
//     uint128 assetsDeposited;
//     uint128 sharesReceived;
//     uint128 assetsFulfilled;
//     require currentContract.depositEpoch() < MAX_UINT128();
//     (assetsDeposited, sharesReceived, assetsFulfilled) = currentContract.getDepositEpochState(currentContract.depositEpoch());
//     return assetsFulfilled;
// }
// invariant totalSupplyGreaterThanZero()
//     currentContract.totalSupply() > 0
//     {
//         preserved {
//             require currentContract.totalSupply() < MAX_UINT128();
//         }
//     }
// invariant totalSupplyGreaterThan0neMillion()
//     currentContract.totalSupply() >= 1000000
//     {
//         preserved with (env e){
//             require e.msg.sender != currentContract;
//             require currentContract.totalSupply() < MAX_UINT128();
//         }
//     }
// invariant solvency1()

//     underlyingToken.balanceOf(currentContract) >= currentContract.reservedWithdrawalAssets()
//     {
//         preserved with (env e){
//             require e.msg.sender != currentContract;
//             require underlyingToken.balanceOf(currentContract) < MAX_UINT128();
//         }
//     }
// invariant solvency2()
//     underlyingToken.balanceOf(currentContract) >= currentContract.reservedWithdrawalAssets() + getAssetDepositedInCurrentEpouch()
//     {
//         preserved with (env e) {
//             require e.msg.sender != currentContract;
//             require underlyingToken.balanceOf(currentContract) < MAX_UINT128() && currentContract.reservedWithdrawalAssets() + getAssetDepositedInCurrentEpouch() < MAX_UINT128();
//         }
//     }
// invariant solvency3()
//     currentContract.reservedWithdrawalAssets() >= getassetsFulfilledInCurrentEpouch()
//     {
//         preserved with (env e){
//             require e.msg.sender != currentContract;
//             require currentContract.reservedWithdrawalAssets() < MAX_UINT128() && getassetsFulfilledInCurrentEpouch() < MAX_UINT128();
//         }
//     }
// invariant solvency()
//     underlyingToken.balanceOf(currentContract) >= currentContract.totalSupply()
//     {
//         preserved with (env e) {
//             require e.msg.sender != currentContract;
//         }
//     } 

// Invariant: A user cannot have shares without having a corresponding basis
// invariant userCannotHaveSharesWithoutBasis(address user)
//     currentContract.balanceOf(user) == 0 || currentContract.userBasis(user) > 0
//     {
//         preserved with (env e) {
//             require e.msg.sender != currentContract;
//             require user != 0; // Exclude zero address
//             require currentContract.balanceOf(user) < MAX_UINT128();
//             require currentContract.userBasis(user) < MAX_UINT128();
//             require currentContract.balanceOf(e.msg.sender) > 0 && currentContract.userBasis(e.msg.sender) > 0;

//         }
//     }

// // Invariant: If a user has shares, they must have basis
// invariant sharesImplyBasis(address user)
//     currentContract.balanceOf(user) > 0 => currentContract.userBasis(user) > 0
//     {
//         preserved with (env e) {
//             require e.msg.sender != currentContract;
//             require user != 0;
//             require currentContract.balanceOf(user) < MAX_UINT128();
//             require currentContract.userBasis(user) < MAX_UINT128();
//             require currentContract.balanceOf(e.msg.sender) > 0 && currentContract.userBasis(e.msg.sender) > 0;

//         }
//     }

// // Invariant: Users with shares must have proportional basis
// invariant sharesBasisConsistency(address user)
//     (currentContract.balanceOf(user) == 0 && currentContract.userBasis(user) == 0) ||
//     (currentContract.balanceOf(user) > 0 && currentContract.userBasis(user) > 0)
//     {
//         preserved with (env e) {
//             require e.msg.sender != currentContract;
//             require user != 0;
//             require currentContract.balanceOf(user) < MAX_UINT128();
//             require currentContract.userBasis(user) < MAX_UINT128();
//             require currentContract.balanceOf(e.msg.sender) > 0 && currentContract.userBasis(e.msg.sender) > 0;

//         }
//     }

// Rule: Transfer should transfer both shares and basis proportionally
rule transferMustTransferSharesAndBasis(address from, address to, uint256 amount) {
    env e;
    
    // Preconditions
    require from != to;
    require from != 0 && to != 0;
    require from != currentContract && to != currentContract;
    
    
    // Get initial states
    uint256 fromSharesBefore = currentContract.balanceOf(from);
    uint256 toSharesBefore = currentContract.balanceOf(to);
    uint256 fromBasisBefore = currentContract.userBasis(from);
    uint256 toBasisBefore = currentContract.userBasis(to);
    
    // Ensure meaningful transfer
    require amount > 0;
    require amount <= fromSharesBefore;
    require fromSharesBefore > 0;
    require fromBasisBefore > 0;
    
    // Prevent overflow
    require fromSharesBefore < MAX_UINT128();
    require toSharesBefore < MAX_UINT128();
    require fromBasisBefore < MAX_UINT128();
    require toBasisBefore < MAX_UINT128();
    require amount < MAX_UINT128();
    
    // Calculate expected basis transfer (proportional to shares)
    mathint expectedBasisTransfer = (to_mathint(fromBasisBefore) * to_mathint(amount)) / to_mathint(fromSharesBefore);
    
    require e.msg.sender == from;

    // Execute transfer
    currentContract.transfer(e, to, amount);
    
    // Get final states
    uint256 fromSharesAfter = currentContract.balanceOf(from);
    uint256 toSharesAfter = currentContract.balanceOf(to);
    uint256 fromBasisAfter = currentContract.userBasis(from);
    uint256 toBasisAfter = currentContract.userBasis(to);
    
    // Assert shares were transferred correctly
    assert to_mathint(fromSharesAfter) == to_mathint(fromSharesBefore) - to_mathint(amount), 
           "From user should lose the transferred shares";
    assert to_mathint(toSharesAfter) == to_mathint(toSharesBefore) + to_mathint(amount), 
           "To user should gain the transferred shares";
    
    // Assert basis was transferred proportionally
    assert to_mathint(fromBasisAfter) == to_mathint(fromBasisBefore) - expectedBasisTransfer, 
           "From user should lose proportional basis";
    assert to_mathint(toBasisAfter) == to_mathint(toBasisBefore) + expectedBasisTransfer, 
           "To user should gain proportional basis";
    
    // Assert invariant is maintained for both users
    assert fromSharesAfter == 0 || fromBasisAfter > 0, 
           "From user: shares without basis invariant violated";
    assert toSharesAfter == 0 || toBasisAfter > 0, 
           "To user: shares without basis invariant violated";
}

 



// function check_shares_recieved_eq_zero() returns bool {
//     uint128 assetsDeposited;
//     uint128 sharesReceived;
//     uint128 assetsFulfilled;
//     require currentContract.depositEpoch() < MAX_UINT128();
//     (assetsDeposited, sharesReceived, assetsFulfilled) = currentContract.getDepositEpochState(currentContract.depositEpoch());
//     return sharesReceived == 0;
// }

// invariant sharesReceived_in_current_epouch_eq_zero()
//     check_shares_recieved_eq_zero();


// // Helper function to check epoch state consistency
// function checkEpochState(uint256 epoch) returns bool {
//     uint128 assetsDeposited;
//     uint128 sharesReceived;
//     uint128 assetsFulfilled;
//     (assetsDeposited, sharesReceived, assetsFulfilled) = currentContract.getDepositEpochState(epoch);
//     return assetsFulfilled <= assetsDeposited && 
//            (assetsFulfilled != 0 || sharesReceived == 0);
// }

// invariant depositEpochStateConsistency(uint256 epoch)
//     checkEpochState(epoch)
//     {
//         preserved {
//             // Ensure epoch is valid
//             require epoch <= currentContract.depositEpoch();
//         }
//     }

// rule cancelDepositMustIncreaseUserBalanceAndReducesVaultTokenBalnce(address depositor){
//     env e;
//     require e.msg.sender != currentContract;
//     require depositor != 0;
//     mathint userBalanceBefore = to_mathint(underlyingToken.balanceOf(depositor));
//     mathint vaultBalanceBefore = to_mathint(underlyingToken.balanceOf(currentContract));
//     require userBalanceBefore < MAX_UINT128() && vaultBalanceBefore < MAX_UINT128();
//     currentContract.cancelDeposit(e, depositor);
//     mathint userBalanceAfter = to_mathint(underlyingToken.balanceOf(depositor));
//     mathint vaultBalanceAfter = to_mathint(underlyingToken.balanceOf(currentContract));
//     assert userBalanceBefore < userBalanceAfter;
//     assert vaultBalanceBefore > vaultBalanceAfter;

// }

    
// rule prop_user_balance_of_increase_after_execute_deposit(address user, uint256 epoch) { //@check
//     env e;
    
//     mathint userBalanceBefore = to_mathint(currentContract.balanceOf(user));
    
//     // Ensure there's actually a deposit to execute
//     require to_mathint(currentContract.queuedDeposit(user, epoch)) > 10000000;
    
//     uint128 assetsDeposited;
//     uint128 sharesReceived; 
//     uint128 assetsFulfilled;
//     assetsDeposited, sharesReceived, assetsFulfilled = currentContract.getDepositEpochState(epoch);
//     require  to_mathint(assetsDeposited) > to_mathint(currentContract.queuedDeposit(user, epoch));
//     // Ensure the epoch has been fulfilled with meaningful amounts
//     require to_mathint(assetsFulfilled) > to_mathint(assetsDeposited / 4);
//     currentContract.executeDeposit(e, user, epoch);
    
//     mathint userBalanceAfter = to_mathint(currentContract.balanceOf(user));
//     assert userBalanceAfter > userBalanceBefore, "User balanceOf should increase after executeDeposit";
// }


// rule prop_user_basis_increase_after_execute_deposit(address user, uint256 epoch) {
//     env e;
    
//     mathint userBasisBefore = to_mathint(currentContract.userBasis(user));
    
//     // Ensure there's actually a deposit to execute
//     require to_mathint(currentContract.queuedDeposit(user, epoch)) > 10000000;
    
//     uint128 assetsDeposited;
//     uint128 sharesReceived; 
//     uint128 assetsFulfilled;
//     assetsDeposited, sharesReceived, assetsFulfilled = currentContract.getDepositEpochState(epoch);
    
//     // Ensure the epoch has been fulfilled with meaningful amounts
//     require to_mathint(assetsFulfilled) > to_mathint(assetsDeposited / 4);
    
//     currentContract.executeDeposit(e, user, epoch);
    
//     mathint userBasisAfter = to_mathint(currentContract.userBasis(user));
//     assert userBasisAfter > userBasisBefore, "User basis should increase after executeDeposit";
// }

// // rule epochMustNotDecrease() {
//     env e;
//     method f;
//     calldataarg args;
//     mathint depositEpochBefore = to_mathint(currentContract.depositEpoch());
//     mathint withdrawalEpochBefore = to_mathint(currentContract.withdrawalEpoch());
//     require depositEpochBefore < MAX_UINT128();
//     require withdrawalEpochBefore < MAX_UINT128();

//     f(e, args);
//     mathint depositEpochAfter = to_mathint(currentContract.depositEpoch());
//     mathint withdrawalEpochAfter = to_mathint(currentContract.withdrawalEpoch());
//     require depositEpochAfter < MAX_UINT128();
//     require withdrawalEpochAfter < MAX_UINT128();
//     assert depositEpochAfter >= depositEpochBefore, "Deposit epoch must not decrease";
//     assert withdrawalEpochAfter >= withdrawalEpochBefore, "Withdrawal epoch must not decrease";
// }

// rule prop_user_basis_increase_after_execute_deposit(address user, uint256 epoch) {
//     env e;
    
//     mathint userBasisBefore = to_mathint(currentContract.userBasis(user));
//     require to_mathint(currentContract.queuedDeposit(user, epoch)) > 10000000000;
    
//     uint128 assetsDeposited;
//     uint128 sharesReceived; 
//     uint128 assetsFulfilled;
//     assetsDeposited, sharesReceived, assetsFulfilled = currentContract.getDepositEpochState(epoch);
    
//     require to_mathint(assetsFulfilled) > to_mathint(assetsDeposited) / 2;
    
//     currentContract.executeDeposit(e, user, epoch);
    
//     mathint userBasisAfter = to_mathint(currentContract.userBasis(user));
//     assert userBasisAfter > userBasisBefore, "User basis should increase after executeDeposit";
// }

