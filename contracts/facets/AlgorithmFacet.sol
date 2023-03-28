// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/math/Math.sol";

import {IAlgorithmFacet} from "../interfaces/IAlgorithmFacet.sol";
import {Constants} from "../libraries/Constants.sol";
import {AppStorage} from "../AppStorage.sol";

library Uint8a32 {
    uint256 constant bits = 8;
    uint256 constant elements = 32;

    uint256 constant range = 1 << bits;
    uint256 constant max = range - 1;

    function get(uint256 va, uint256 index) internal pure returns (uint256) {
        require(index < elements);
        return (va >> (bits * index)) & max;
    }

    function set(
        uint256 va,
        uint256 index,
        uint256 ev
    ) internal pure returns (uint256) {
        require(index < elements);
        require(ev < range);
        index *= bits;
        return (va & ~(max << index)) | (ev << index);
    }
}

contract AlgorithmFacet {
    using Uint8a32 for uint256;

    AppStorage s;

    function calculateLotteryReward(
        uint256 _seed,
        uint256 _count,
        uint256 _bonusPool,
        uint256 _jackPool,
        uint256 _decimals
    )
        external
        view
        returns (
            uint256 result,
            uint256 bonus,
            uint256 jack
        )
    {
        unchecked {
            uint256 jackpotThreshold = _getJackThreshold(
                _jackPool / 10**_decimals
            );
            uint256[] memory stats = new uint256[](14);

            for (uint256 i; i < _count; ) {
                uint256 rand = uint256(keccak256(abi.encode(_seed, i))) %
                    Constants.WEIGHT_SCOPE;
                uint256 index = _getIndex(rand);
                uint256 reward = s.rewards[index];

                if (index == 0 || reward * 10**_decimals > _bonusPool / 11) {
                    if (rand <= jackpotThreshold) {
                        stats[Constants.JACKPOT_INDEX]++;
                    } else {
                        stats[0]++;
                    }
                } else {
                    stats[index]++;
                    _bonusPool = _bonusPool - reward;
                }
                ++i;
            }

            for (uint256 i; i <= 12; ) {
                if (stats[i] > 0) {
                    result = result.set(i, stats[i]);
                    bonus = bonus + (s.rewards[i] * 10**_decimals) * stats[i];
                }
                ++i;
            }
            
            result = result.set(
                Constants.JACKPOT_INDEX,
                stats[Constants.JACKPOT_INDEX]
            );
            jack += _jackPool - (_jackPool / 2**stats[Constants.JACKPOT_INDEX]);
        }
    }

    function calculateMintAmount(
        uint256 _value,
        uint256 _currencyDecimals,
        uint256 _valuesDecimals
    ) external view returns (uint256) {
        unchecked {
            uint256 fib = _findNextFibonacci(
                _value / (10000 * 10**_currencyDecimals)
            );
            return (4200000 / fib) * 10**_valuesDecimals;
        }
    }

    function _getJackThreshold(uint256 _value) internal pure returns (uint256) {
        if (_value >= 1000000) return 11303;
        unchecked {
            uint256 probability = Math.min(_value, 1000000) * 49 + 10**6;
            return (probability * 226061063) / 10**12;
        }
    }

    function _getIndex(uint256 _value) internal view returns (uint256 index) {
        if (_value == 0) {
            return 12;
        }

        unchecked {
            uint256 lo = 0;
            uint256 hi = Constants.INTVALS_LENGTH - 1;
            while (lo < hi) {
                uint256 mid = (lo + hi + 1) / 2;
                if (s.intvals[mid] <= _value) {
                    lo = mid;
                } else {
                    hi = mid - 1;
                }
            }
            index = 11 - lo;
        }
    }

    function _findNextFibonacci(uint256 input) internal view returns (uint256) {
        unchecked {
            uint256 low = 0;
            uint256 high = Constants.FIBONACCI_LENGTH - 1;
            uint256 mid;

            while (low < high) {
                mid = (low + high) / 2;
                uint256 v = s.fibonacci[mid];
                if (v == input) {
                    return s.fibonacci[mid + 1];
                } else if (v < input) {
                    low = mid + 1;
                } else {
                    high = mid;
                }
            }
            return s.fibonacci[low];
        }
    }
}
