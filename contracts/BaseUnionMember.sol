//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IMarketRegistry.sol";
import "./interfaces/IUserManager.sol";
import "./interfaces/IUToken.sol";

/**
 * @title BaseUnionMember Contract
 * @dev This contract has the basic functions of Union member.
 */
abstract contract BaseUnionMember {
    IMarketRegistry public immutable marketRegistry;
    IUserManager public immutable userManager;
    IUToken public immutable uToken;
    IERC20 public immutable unionToken;
    IERC20 public immutable underlyingToken;

    /**
     *  @dev Constructor
     *  @param _marketRegistry Union's MarketRegistry contract address
     *  @param _unionToken UNION token address
     *  @param _underlyingToken Underlying asset address
     */
    constructor(address _marketRegistry, address _unionToken, address _underlyingToken) {
        (address _uToken, address _userManager) = IMarketRegistry(_marketRegistry).tokens(_underlyingToken);
        marketRegistry = IMarketRegistry(_marketRegistry);
        userManager = IUserManager(_userManager);
        uToken = IUToken(_uToken);
        unionToken = IERC20(_unionToken);
        underlyingToken = IERC20(_underlyingToken);
    }

    /**
     *  @dev Return member's status
     *  @return Member's status
     */
    function isMember() public view returns (bool) {
        return userManager.checkIsMember(address(this));
    }

    /**
     *  @dev Register to become a Union member
     */
    function _registerMember() internal {
        uint256 newMemberFee = userManager.newMemberFee();
        unionToken.approve(address(userManager), newMemberFee);
        userManager.registerMember(address(this));
    }
}