//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IMarketRegistry.sol";
import "./interfaces/IUserManager.sol";

contract UnionVoucher {
    IMarketRegistry public immutable marketRegistry;
    IUserManager public immutable userManager;
    IERC20 public immutable unionToken;
    IERC20 public immutable underlyingToken;
    constructor(address _marketRegistry, address _unionToken, address _underlyingToken) {
        (, address _userManager) = IMarketRegistry(_marketRegistry).tokens(_underlyingToken);
        marketRegistry = IMarketRegistry(_marketRegistry);
        userManager = IUserManager(_userManager);
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
    
    // get the user's deposited stake amount
    function getStakerBalance() public view returns (uint256) {
        return userManager.getStakerBalance(address(this));
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
        underlyingToken.approve(address(userManager), amount);
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
}