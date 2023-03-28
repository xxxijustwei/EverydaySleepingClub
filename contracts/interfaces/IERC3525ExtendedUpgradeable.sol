// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;

interface IERC3525ExtendedUpgradeable {

    function getUserFirstTokenIdInSlot(address _owner, uint _slot) external view returns (uint tokenId_);

    function getTokenIndexInSlot(uint _tokenId) external view returns (uint index_);

    function getTokenIdInSlot(uint _slot, uint _index) external view returns (uint tokenId_);

    function getOwnerInSlot(uint _slot, uint _index) external view returns (address owner_);

    function slotBalanceOf(uint _slot, address _owner) external view returns (uint count_);

    function slotCurrentSupply(uint _slot) external view returns (uint supply_);

    function transferFromSlot(
        uint _fromIndex,
        uint _toIndex,
        uint _slot,
        uint _value
    ) external payable;
    
    function transferFromSlot(
        uint _fromIndex,
        address _to,
        uint _slot,
        uint _value
    ) external payable returns (uint);

    function transferFromSlot(
        address _from,
        address _to,
        uint _index,
        uint _slot
    ) external payable;

    function safeTransferFromSlot(
        address _from,
        address _to,
        uint _index,
        uint _slot,
        bytes memory _data
    ) external payable;

    function safeTransferFromSlot(
        address _from,
        address _to,
        uint _index,
        uint _slot
    ) external payable;
}