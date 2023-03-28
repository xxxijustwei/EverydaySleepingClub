// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

interface IAdminFacet {

    function initPot(uint _bonusPot, uint _jackPot) external;

    function randomizerWithdraw(address _user, uint256 _amount) external;

    function setCurrency(address _addr) external;

    function setRandomizer(address _addr) external;

    function setVoucher(address _addr) external;

    function currency() external view returns (address);

    function randomizer() external view returns (address);

    function voucher() external view returns (address);

}