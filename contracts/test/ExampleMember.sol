//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../UnionVoucher.sol";
import "../UnionBorrower.sol";

contract ExampleMember is Ownable, UnionVoucher, UnionBorrower{
    constructor(address marketRegistry, address unionToken, address token) BaseUnionMember(marketRegistry,unionToken,token){
     
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

    function borrow(uint256 amount) public onlyOwner {
        _borrow(amount);
        underlyingToken.transfer(msg.sender, amount);
    }

    function repayBorrow(uint256 amount) public onlyOwner {
        underlyingToken.transferFrom(msg.sender, address(this), amount);
        _repayBorrow(amount);
    }

    function repayBorrowBehalf(address account, uint256 amount) public onlyOwner {
        underlyingToken.transferFrom(msg.sender, address(this), amount);
        _repayBorrowBehalf(account, amount);
    }
    
    function mint(uint256 amount) public onlyOwner {
        underlyingToken.transferFrom(msg.sender, address(this), amount);
        _mint(amount);
    }
    
    // sender redeems uTokens in exchange for the underlying asset
    function redeem(uint256 amount) public onlyOwner {
        _redeem(amount);
        underlyingToken.transfer(msg.sender, underlyingToken.balanceOf(address(this)));
    }

    // sender redeems uTokens in exchange for a specified amount of underlying asset
    function redeemUnderlying(uint256 amount) public onlyOwner {
        _redeemUnderlying(amount);
        underlyingToken.transfer(msg.sender, underlyingToken.balanceOf(address(this)));
    }
}