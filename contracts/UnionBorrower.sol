//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IMarketRegistry.sol";
import "./interfaces/IUserManager.sol";
import "./interfaces/IUToken.sol";
import "./BaseUnionMember.sol";

abstract contract UnionBorrower is BaseUnionMember {
    function getStakerAddresses() public view returns (address[] memory) {
        return userManager.getStakerAddresses(address(this));
    }

    // get the member's available credit line
    function getCreditLimit() public view returns (int256) {
        return userManager.getCreditLimit(address(this));
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
    
    function _borrow(uint256 amount) internal {
        uToken.borrow(amount);
    }

    function _repayBorrow(uint256 amount) internal {
        underlyingToken.approve(address(uToken), amount);
        uToken.repayBorrow(amount);
    }

    function _repayBorrowBehalf(address account, uint256 amount) internal {
        underlyingToken.approve(address(uToken), amount);
        uToken.repayBorrowBehalf(account, amount);
    }
    
    function _mint(uint256 amount) internal {
        underlyingToken.approve(address(uToken), amount);
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