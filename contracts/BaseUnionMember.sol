//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IMarketRegistry.sol";
import "./interfaces/IUserManager.sol";
import "./interfaces/IUToken.sol";

abstract contract BaseUnionMember {
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

    //become a member
    function _registerMember() internal {
        uint256 newMemberFee = userManager.newMemberFee();
        unionToken.approve(address(userManager), newMemberFee);
        userManager.registerMember(address(this));
    }
}