//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IMarketRegistry.sol";
import "./interfaces/IUserManager.sol";
import "./interfaces/IUToken.sol";

contract UnionBorrower {
    IMarketRegistry public immutable marketRegistry;
    IUserManager public immutable userManager;
    IUToken public immutable uToken;
    IERC20 public immutable unionToken;
    IERC20 public immutable underlyingToken;
    constructor(address _marketRegistry, address _unionToken, address _underlyingToken) {
        (address _uToken, address _userManager) = IMarketRegistry(_marketRegistry).tokens(_underlyingToken);
        marketRegistry = IMarketRegistry(_marketRegistry);
        userManager = IUserManager(_userManager);
        uToken = IUToken(_uToken);
        unionToken = IERC20(_unionToken);
        underlyingToken = IERC20(_underlyingToken);
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
        underlyingToken.redeem(amount);
    }

    // sender redeems uTokens in exchange for a specified amount of underlying asset
    function _redeemUnderlying(uint256 amount) internal {
        underlyingToken.redeemUnderlying(amount);
    }   
}