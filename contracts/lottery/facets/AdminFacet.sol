// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { IAdminFacet } from "../../interfaces/lottery/IAdminFacet.sol";
import { IRandomizer } from "../../interfaces/IRandomizer.sol";
import { LibDiamond } from "../../libraries/LibDiamond.sol";
import { Events } from "../libraries/Events.sol";
import { AppStorage } from "../AppStorage.sol";

contract AdminFacet is IAdminFacet {

    error WithdrawOverPot();
    error InsufficientLiquidity();
    error FundsIsZero();

    function initPot(uint _bonusPot, uint _jackPot) external {
        LibDiamond.enforceIsContractOwner();

        if (_bonusPot == 0) revert FundsIsZero();
        if (_jackPot == 0) revert FundsIsZero();

        AppStorage.State storage s = AppStorage.get();

        uint total = _bonusPot + _jackPot;
        _currency().transferFrom(msg.sender, address(this), total);
        s.basePot = s.basePot + total;
        s.bonusPot = s.bonusPot + _bonusPot;
        s.jackPot = s.jackPot + _jackPot;

        emit Events.InitLotteryPot(msg.sender, _bonusPot, _jackPot);
    }

    function withdrawPot(address _to, uint _value) external {
        LibDiamond.enforceIsContractOwner();

        AppStorage.State storage s = AppStorage.get();

        if (s.basePot < _value) revert WithdrawOverPot();
        if (s.bonusPot + s.jackPot < _value) revert InsufficientLiquidity();

        if (s.jackPot >= _value) {
            s.jackPot = s.jackPot - _value;
        } else {
            uint funds = s.jackPot;
            s.jackPot = 0;
            s.bonusPot = s.bonusPot - (_value - funds);
        }

        _currency().transfer(_to, _value);

        emit Events.WithdrawLotteryPot(msg.sender, _to, _value);
    }

    function randomizerWithdraw(address _user, uint256 _amount) external {
        LibDiamond.enforceIsContractOwner();
        IRandomizer(AppStorage.get().randomizer).clientWithdrawTo(_user, _amount);
    }

    function setCurrency(address _addr) external {
        LibDiamond.enforceIsContractOwner();
        AppStorage.get().currency = _addr;
    }

    function setRandomizer(address _addr) external {
        LibDiamond.enforceIsContractOwner();
        AppStorage.get().randomizer = _addr;
    }

    function setVoucher(address _addr) external {
        LibDiamond.enforceIsContractOwner();
        AppStorage.get().voucher = _addr;
    }

    function getCurrency() external view returns (address) {
        return AppStorage.get().currency;
    }

    function getRandomizer() external view returns (address) {
        return AppStorage.get().randomizer;
    }

    function getVoucher() external view returns (address) {
        return AppStorage.get().voucher;
    }

    function _currency() internal view returns (IERC20) {
        return IERC20(AppStorage.get().currency);
    }
}