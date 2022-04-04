//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IMarketRegistry.sol";
import "./interfaces/IUserManager.sol";
import "./interfaces/IUToken.sol";
import "./BaseUnionMember.sol";

/**
 * @title UnionBorrower Contract
 * @dev This contract has all the functions of Union borrower role.
 */
abstract contract UnionBorrower is BaseUnionMember {
    /**
     *  @dev Get all the vouchers' addresses
     *  @return Vouchers' addresses
     */
    function getStakerAddresses() public view returns (address[] memory) {
        return userManager.getStakerAddresses(address(this));
    }

    /**
     *  @dev Get the member's available credit line
     *  @return Member's total credit limit
     */
    function getCreditLimit() public view returns (int256) {
        return userManager.getCreditLimit(address(this));
    }

    /**
     *  @dev Return the block of last repayment
     *  @return Last repayment block number
     */
    function getLastRepay() public view returns (uint256) {
        return uToken.getLastRepay(address(this));
    }

    /**
     *  @dev Check to see if the user's loan is overdue
     *  @return If the loan is overdue
     */
    function isOverdue() public view returns (bool) {
        return uToken.checkIsOverdue(address(this));
    }

    /**
     *  @dev Return user's loan principle
     *  @return Amount of loan principle (in wei)
     */
    function getBorrowed() public view returns (uint256) {
        return uToken.getBorrowed(address(this));
    }

    /**
     *  @dev Return user's total owed balance, including the principle and interest.
     *  @return Amount of total owed (in wei)
     */
    function borrowBalanceView() public view returns (uint256) {
        return uToken.borrowBalanceView(address(this));
    }
    
    /**
     *  @dev Borrow amount must be within the range of creditLimit, minBorrow, maxBorrow, and debtCeiling 
     *  and the borrower's loan is not overdue
     *  @param amount Amount to borrow (in wei)
     */
    function _borrow(uint256 amount) internal {
        uToken.borrow(amount);
    }

    /**
     *  @dev Repay the loan
     *  @param amount Amount to repay (in wei)
     */
    function _repayBorrow(uint256 amount) internal {
        underlyingToken.approve(address(uToken), amount);
        uToken.repayBorrow(amount);
    }

    /**
     *  @dev Repay the loan
     *  @param account Borrower's address
     *  @param amount Amount to repay (in wei)
     */
    function _repayBorrowBehalf(address account, uint256 amount) internal {
        underlyingToken.approve(address(uToken), amount);
        uToken.repayBorrowBehalf(account, amount);
    }
    
    /**
     *  @dev Supply the underlying token to get uTokens
     *  @param amount Amount to supply (in wei)
     */
    function _mint(uint256 amount) internal {
        underlyingToken.approve(address(uToken), amount);
        uToken.mint(amount);
    }
    
    /**
     * @dev Withdraw the underlying token by redeeming uToken
     * @param amount Amount of uToken to redeem (in wei)
     */
    function _redeem(uint256 amount) internal {
        uToken.redeem(amount);
    }

    /**
     * @dev Withdraw the underlying token by redeeming uToken
     * @param amount Amount of underlying token (in wei)
     */
    function _redeemUnderlying(uint256 amount) internal {
        uToken.redeemUnderlying(amount);
    }   
}