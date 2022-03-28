//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IMarketRegistry.sol";
import "./interfaces/IUserManager.sol";
import "./BaseUnionMember.sol";

contract UnionVoucher is BaseUnionMember{
    constructor(address _marketRegistry, address _unionToken, address _underlyingToken) BaseUnionMember(_marketRegistry,_unionToken,_underlyingToken){
 
    }

    function getBorrowerAddresses() public view returns (address[] memory) {
        return userManager.getBorrowerAddresses(address(this));
    }
    
    // get the user's deposited stake amount
    function getStakerBalance() public view returns (uint256) {
        return userManager.getStakerBalance(address(this));
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