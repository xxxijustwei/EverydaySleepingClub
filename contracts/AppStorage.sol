// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "./libraries/Structs.sol";

struct AppStorage {

    address currency;
    address randomizer;
    address voucher;

    uint basePot;
    uint bonusPot;
    uint jackPot;
    uint protocolIncome;

    uint totalPayin;
    uint totalPayout;

    uint cyclePrevious;
    uint cycleCurrent;
    uint cycleProgress;

    uint[] intvals;
    uint[] rewards;
    uint[] fibonacci;
    
    uint[50] gaps;

    mapping(uint => LotteryRequest) playerRequest;
    mapping(address => uint) playerExpend;
    mapping(address => uint) playerIncome;
    mapping(address => bool) claim;
}