// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

interface IAlgorithmFacet {

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
        );
    
    function calculateMintAmount(
        uint256 _value,
        uint256 _currencyDecimals,
        uint256 _valuesDecimals
    ) external view returns (uint256);
}