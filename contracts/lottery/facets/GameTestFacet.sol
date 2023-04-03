// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@solvprotocol/erc-3525/IERC3525.sol";

import {AppStorage} from "../AppStorage.sol";
import {IGameFacet} from "../../interfaces/lottery/IGameFacet.sol";
import {IAlgorithmFacet} from "../../interfaces/lottery/IAlgorithmFacet.sol";
import {IPlayground} from "../../interfaces/voucher/IPlayground.sol";
import {IRandomizer} from "../../interfaces/IRandomizer.sol";
import {Events} from "../libraries/Events.sol";
import "../libraries/Structs.sol";

contract GameTestFacet is IGameFacet {

    error Unauthorized();
    error AddressIsZero();
    error InvalidTimes();
    
    function play(address _player, uint256 _times) external returns (uint quantity) {
        AppStorage.State storage s = AppStorage.get();

        require(_player != address(0), "AddressIsZero");
        require(_times <= 100, "InvalidTimes");

        uint256 gasLimit = _playGasLimit(_times);

        IERC20Metadata usdt = _currency();
        uint256 payin = _price() * _times;
        usdt.transferFrom(msg.sender, address(this), payin);

        quantity = IAlgorithmFacet(address(this)).calculateMintAmount(
            s.totalPayin,
            usdt.decimals(),
            IERC3525(s.voucher).valueDecimals()
        );

        uint256 per = payin / 100;
        s.bonusPot = s.bonusPot + per * 78;
        s.jackPot = s.jackPot + per * 12;

        s.playerExpend[_player] += payin;
        s.totalPayin = s.totalPayin + payin;

        uint256 id = _randomizer().request(gasLimit);
        LotteryRequest storage req = s.playerRequest[id];
        req.player = msg.sender;
        req.times = _times;
    }

    function randomizerCallback(uint256 _id, bytes32 _value) external {
        AppStorage.State storage s = AppStorage.get();
        // require(msg.sender == s.randomizer, "Unauthorized");

        LotteryRequest memory req = s.playerRequest[_id];
        (uint256 result, uint256 bonus, uint256 jack) = IAlgorithmFacet(
            address(this)
        ).calculateLotteryReward(
                uint256(_value),
                req.times,
                s.bonusPot,
                s.jackPot,
                _currency().decimals()
            );

        uint256 bonusTax;
        uint256 jackTax;

        if (bonus > 0) {
            bonusTax = bonus / 50;
            s.bonusPot -= bonus;
        }
        if (jack > 0) {
            jackTax = jack / 50;
            s.jackPot -= jack;
        }

        uint256 payout = (bonus - bonusTax) + (jack - jackTax);
        _currency().transfer(req.player, payout);

        s.playerIncome[req.player] += payout;
        s.totalPayout = s.totalPayout + payout;
        s.protocolIncome = s.protocolIncome + (bonusTax + jackTax);

        emit Events.LotteryResult(req.player, result, bonus, jack);
    }

    function testCallback(uint _seed, uint _times) external {
        AppStorage.State storage s = AppStorage.get();
        // require(msg.sender == s.randomizer, "Unauthorized");

        (uint256 result, uint256 bonus, uint256 jack) = IAlgorithmFacet(
            address(this)
        ).calculateLotteryReward(
                _seed,
                _times,
                s.bonusPot,
                s.jackPot,
                _currency().decimals()
            );

        uint256 bonusTax;
        uint256 jackTax;

        if (bonus > 0) {
            bonusTax = bonus / 50;
            s.bonusPot -= bonus;
        }
        if (jack > 0) {
            jackTax = jack / 50;
            s.jackPot -= jack;
        }

        uint256 payout = (bonus - bonusTax) + (jack - jackTax);
        _currency().transfer(msg.sender, payout);

        s.playerIncome[msg.sender] += payout;
        s.totalPayout = s.totalPayout + payout;
        s.protocolIncome = s.protocolIncome + (bonusTax + jackTax);

        emit Events.LotteryResult(msg.sender, result, bonus, jack);
    }

    function estimateFee(uint times) external view returns (uint) {
        return _randomizer().estimateFee(_playGasLimit(times));
    }

    function _playGasLimit(uint _times) internal pure returns (uint) {
        return 80000 + _times * 3000;
    }

    function _next(uint256 a, uint256 b) internal pure returns (uint256, uint256) {
        return (b, (b * 1191) / 1000 - (b - a));
    }

    function price() external view returns (uint256) {
        return _price();
    }

    function currency() external view returns (address) {
        return AppStorage.get().currency;
    }

    function voucherRatio() external pure returns (uint256) {
        return 10;
    }

    function valuesTotalSupply() external pure returns (uint256) {
        return 21 * 10**10;
    }

    function premitQuantity() external pure returns (uint256) {
        return 21 * 10**9;
    }

    function _currency() internal view returns (IERC20Metadata) {
        return IERC20Metadata(AppStorage.get().currency);
    }

    function _randomizer() internal view returns (IRandomizer) {
        return IRandomizer(AppStorage.get().randomizer);
    }

    function _voucher() internal view returns (IPlayground) {
        return IPlayground(AppStorage.get().voucher);
    }

    function _price() internal view returns (uint256) {
        return 2 * 10**_currency().decimals();
    }

    function _slot() internal pure returns (uint256) {
        return 100;
    }
}
