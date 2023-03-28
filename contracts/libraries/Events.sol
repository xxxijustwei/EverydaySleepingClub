// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

library Events {

    event LotteryPlay(address indexed player, uint indexed requestId, uint count);
    event LotteryResult(address indexed player, uint indexed result, uint bonus, uint jack);

    event JackpotDividends(uint previous, uint current, uint value);

    event InitLotteryPot(address indexed admin, uint bonusPot, uint jackPot);
    event WithdrawLotteryPot(address indexed admin, address indexed receiver, uint funds);
}