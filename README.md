# Union SDK

[![npm version](https://badge.fury.io/js/@unioncredit%2Fv1-sdk.svg)](https://badge.fury.io/js/@unioncredit%2Fv1-sdk)

A library to help developers build own contracts that interact with [Union protocol](https://union.finance).

## Structure

- [BaseUnionMember](./contracts/BaseUnionMember.sol) - has the basic functions of Union member.
- [UnionBorrower](./contracts/UnionBorrower.sol) - implements all the functions of a Union member that can borrower from other members.
- [UnionVoucher](./contracts/UnionVoucher.sol) - implements all the functions of Union member that can vouch for other members.

## Getting Started

### Installation

```
npm install @unioncredit/v1-sdk
```

### Imports

```solidity
import "@unioncredit/v1-sdk/contracts/BaseUnionMember.sol";
import "@unioncredit/v1-sdk/contracts/UnionVoucher.sol";
import "@unioncredit/v1-sdk/contracts/UnionBorrower.sol";
```

### Example Borrower

An example implementation of a contract that is a Union member. Once registered this contract would be able to
borrow DAI and use it to buy [OSQTH](https://www.opyn.co/).

```solidity
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@unioncredit/v1-sdk/contracts/UnionBorrower.sol";

/**
 * @notice A UnionMember that borrows DAI to go long on OSQTH
 */
contract SqueethWithFriends is UnionBorrower {
  address public dai;
  
  constructor(address _dai) {
    dai = _dai;
  }
  
  function borrowAndSqueeth(uint256 _amountInDai) external {
    _borrow(_amountInDai);
    _investInSqueeth(_amountInDai);
  }
  
  function sellAndRepay(uint _amountInSqueeth) external {
    _sellSqueeth(_amountInSqueeth);
    uint balance = IERC20(dai).balanceOf(address(this));
    _repayBorrow(balance);
  }
  
  function _investInSqueeth(uint256 _amountInDai) internal {
    // buy OSQTH with DAI
  }
  
  function _sellSqueeth(uint256 _amountInSqueeth) internal {
    // sell OSQTH for DAI
  }
}
```

### Example Voucher

An example implementation of a contract that is a Union member. Once registered this contract would be able to
vouch for [frankfrank](https://opensea.io/collection/frankfrank) holders.

```solidity
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@unioncredit/v1-sdk/contracts/UnionVoucher.sol";

/**
 * @notice A UnionMember that vouches for holders of frankfrank
 */
contract FrankFrankFriends is UnionVoucher {
  uint256 public vouchAmount;
  IERC721 public frank;
  
  constructor(uint _vouchAmount, IERC721 _frank) {
    vouchAmount = _vouchAmount;
    frank = _frank;
  }
  
  function stake() external {
    uint balance = IERC20(dai).balanceOf(address(this));
    _stake(balance);
  }
  
  function vouchForFrankFrank(address holder) external {
    require(frank.balanceOf(holder) > 0, "!holder");
    _updateTrust(holder, vouchAmount);
  }
  
  function cancelPaperHands(address holder) external {
    require(frank.balanceOf(holder) <= 0, "!paper hands");
    _cancelVouch(holder);
  }
}
```
