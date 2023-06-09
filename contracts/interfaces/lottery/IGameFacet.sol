// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

interface IGameFacet {

    function play(address _player, uint _count) external returns (uint quantity);

    function estimateFee(uint times) external view returns (uint);

    function price() external view returns (uint);

    function currency() external view returns (address);
    
    function voucherRatio() external view returns (uint);

    function valuesTotalSupply() external view returns (uint);

    function premitQuantity() external view returns (uint);

}