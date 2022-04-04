//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../UnionVoucher.sol";

contract ExampleVoucher is Ownable, UnionVoucher{
    constructor(address marketRegistry, address unionToken, address token) BaseUnionMember(marketRegistry,unionToken,token) {
     
    }

    //become a member
    function registerMember() public onlyOwner {
        uint256 newMemberFee = userManager.newMemberFee();
        unionToken.transferFrom(msg.sender, address(this), newMemberFee);
        _registerMember();
    }

    // update trust for account
    function updateTrust(address account, uint256 amount) public onlyOwner {
        _updateTrust(account, amount);
    }

    // stop vouch for other member
    function cancelVouch(address staker, address borrower) public onlyOwner {
        _cancelVouch(staker, borrower);
    }

    function stake(uint256 amount) public onlyOwner {
        underlyingToken.transferFrom(msg.sender, address(this), amount);
        _stake(amount);
    }

    function unstake(uint256 amount) public onlyOwner {
        _unstake(amount);
        underlyingToken.transfer(msg.sender, amount);
    }

    function withdrawRewards() public onlyOwner {
        _withdrawRewards();
        unionToken.transfer(msg.sender, unionToken.balanceOf(address(this)));
    }
    
    function debtWriteOff(address borrower, uint256 amount) public onlyOwner {
        _debtWriteOff(borrower, amount);
    }
}