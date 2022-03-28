//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IMarketRegistry.sol";
import "./interfaces/IUserManager.sol";
import "./interfaces/IUToken.sol";

contract UnionMember {
    IMarketRegistry public immutable marketRegistry;
    IUserManager public immutable userManager;
    IUToken public immutable uToken;
    IERC20 public immutable unionToken;
    IERC20 public immutable token;
    constructor(address _marketRegistry, address _unionToken, address _token) {
        (address _uToken, address _userManager) = IMarketRegistry(_marketRegistry).tokens(_token);
        marketRegistry = IMarketRegistry(_marketRegistry);
        userManager = IUserManager(_userManager);
        uToken = IUToken(_uToken);
        unionToken = IERC20(_unionToken);
        token = IERC20(_token);
    }

    function isMember() public view returns (bool) {
        return userManager.checkIsMember(address(this));
    }

    function getBorrowerAddresses() public view returns (address[] memory) {
        return userManager.getBorrowerAddresses(address(this));
    }

    function getStakerAddresses() public view returns (address[] memory) {
        return userManager.getStakerAddresses(address(this));
    }

    // get the member's available credit line
    function getCreditLimit() public view returns (int256) {
        return userManager.getCreditLimit(address(this));
    }
    
    // get the user's deposited stake amount
    function getStakerBalance() public view returns (uint256) {
        return userManager.getStakerBalance(address(this));
    }

    function getLastRepay() public view returns (uint256) {
        return uToken.getLastRepay(address(this));
    }

    function isOverdue() public view returns (bool) {
        return uToken.checkIsOverdue(address(this));
    }

    // get the borrowed principle
    function getBorrowed() public view returns (uint256) {
        return uToken.getBorrowed(address(this));
    }

    // get a member's current owed balance, including the principle and interest.
    function borrowBalanceView() public view returns (uint256) {
        return uToken.borrowBalanceView(address(this));
    }

    //become a member
    function _registerMember() internal {
        uint256 newMemberFee = userManager.newMemberFee();
        unionToken.approve(address(userManager), newMemberFee);
        userManager.registerMember(address(this));
    }

    // update trust for account
    function _updateTrust(address account, uint256 amount) internal {
        userManager.updateTrust(account, amount);
    }

    // stop vouch for other member
    function _cancelVouch(address staker, address borrower) internal {
        userManager.cancelVouch(staker, borrower);
    }

    function _stake(uint256 amount) internal {
        token.approve(address(userManager), amount);
        userManager.stake(amount);
    }

    function _unstake(uint256 amount) internal {
        userManager.unstake(amount);
    }

    function _withdrawRewards() internal {
        userManager.withdrawRewards();
    }
    
    function _debtWriteOff(address borrower, uint256 amount) internal {
        userManager.debtWriteOff(borrower, amount);
    }
    
    function _borrow(uint256 amount) internal {
        uToken.borrow(amount);
    }

    function _repayBorrow(uint256 amount) internal {
        token.approve(address(uToken), amount);
        uToken.repayBorrow(amount);
    }

    function _repayBorrowBehalf(address account, uint256 amount) internal {
        token.approve(address(uToken), amount);
        uToken.repayBorrowBehalf(account, amount);
    }
    
    function _mint(uint256 amount) internal {
        token.approve(address(uToken), amount);
        uToken.mint(amount);
    }
    
    // sender redeems uTokens in exchange for the underlying asset
    function _redeem(uint256 amount) internal {
        uToken.redeem(amount);
    }

    // sender redeems uTokens in exchange for a specified amount of underlying asset
    function _redeemUnderlying(uint256 amount) internal {
        uToken.redeemUnderlying(amount);
    }   
}