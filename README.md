# Union SDK

A library to help developers to easily build their own contracts to interact with [Union protocol](https://union.finance).

## Structure

- [BaseUnionMember](./contracts/BaseUnionMember.sol) - has the basic functions of Union member.
- [UnionBorrower](./contracts/UnionBorrower.sol) - implements all the functions of Union borrower role.
- [UnionVoucher](./contracts/UnionVoucher.sol) - implements all the functions of Union voucher role.

## How to Use

Simply use `UnionBorrower` as the parent class if you just want to setup your contract to be a Union borrower, or use `UnionVoucher` if you want your contract to vouch for others. You can also inheret both `UnionBorrower` and `UnionVoucher` to have all the functions for your contract.

You can also find the example code snippets [here](./contracts//test/) in the repo.
