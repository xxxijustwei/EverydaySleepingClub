// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

interface IPlayground {

    event UserMintShares(address indexed _user, uint indexed _slot, uint _amount);
    event UserBurnShares(address indexed _user, uint indexed _slot, uint _amount, uint _value);
    event DividendPoolChange(uint indexed _slot, uint _total, uint _current, uint _value);
    event UserClaimDividend(address indexed _user, uint indexed _slot, uint _value);

    function registerGame(uint _slot, address _game, uint _sharesFunds) external;

    function setEnable(uint _slot, bool _off) external;
    
    function isEnable(uint _slot) external view returns (bool);

    function addDividendPool(uint _slot, uint _amount) external;

    function getUserSharesValue(address _user, uint _slot) external view returns (uint);
}