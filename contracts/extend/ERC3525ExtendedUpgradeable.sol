// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "@solvprotocol/erc-3525/ERC3525Upgradeable.sol";
import "@solvprotocol/erc-3525/periphery/interface/IERC3525MetadataDescriptorUpgradeable.sol";

import "../interfaces/IERC3525ExtendedUpgradeable.sol";


contract ERC3525ExtendedUpgradeable is Initializable, ContextUpgradeable, ERC3525Upgradeable, IERC3525ExtendedUpgradeable {

    using StringsUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    struct SlotData {
        uint currentSupply;
        CountersUpgradeable.Counter counter;
        mapping(uint => uint) tokenIdToIndex;
        mapping(uint => uint) indexToTokenId;
        mapping(uint => address) indexToOwner;
        mapping(address => uint) balanceOf;
    }

    mapping(uint => address) private _slotDescriptor;
    mapping(uint => bool) private _slotExists;

    mapping(address => mapping(uint => uint)) private _slotFirstToken;
    mapping(uint => SlotData) private _slotDatum;

    function __ERC3525Extended_init(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) internal onlyInitializing {
        __ERC3525_init_unchained(name_, symbol_, decimals_);
    }

    function __ERC3525Extended_init_unchained(
        string memory,
        string memory,
        uint8
    ) internal onlyInitializing {
    }

    function getUserFirstTokenIdInSlot(address _owner, uint _slot) public view virtual override returns (uint tokenId_) {
        tokenId_ = _userFirstTokenIdInSlot(_owner, _slot);
    }

    function getTokenIndexInSlot(uint _tokenId) public view virtual override returns (uint index_) {
        index_ = _tokenIndexInSlot(_tokenId);
    }

    function getTokenIdInSlot(uint _slot, uint _index) public view virtual override returns (uint tokenId_) {
        tokenId_ = _tokenIdInSlot(_slot, _index);
    }

    function getOwnerInSlot(uint _slot, uint _index) public view virtual override returns (address owner_) {
        owner_ = _onwerInSlot(_slot, _index);
    }

    function slotBalanceOf(uint _slot, address _owner) public view virtual override returns (uint count_) {
        count_ = _slotBalanceOf(_slot, _owner);
    }

    function slotCurrentSupply(uint _slot) external view virtual override returns (uint supply_) {
        supply_ = _slotCurrentSupply(_slot);
    }

    function _userFirstTokenIdInSlot(address _owner, uint _slot) internal view returns (uint) {
        return _slotFirstToken[_owner][_slot];
    }

    function _tokenIndexInSlot(uint _tokenId) internal view returns (uint) {
        uint slot = ERC3525Upgradeable.slotOf(_tokenId);
        return _slotDatum[slot].tokenIdToIndex[_tokenId];
    }

    function _tokenIdInSlot(uint _slot, uint _index) internal view returns (uint) {
        return _slotDatum[_slot].indexToTokenId[_index];
    }

    function _onwerInSlot(uint _slot, uint _index) internal view returns (address) {
        return _slotDatum[_slot].indexToOwner[_index];
    }

    function _slotBalanceOf(uint _slot, address _owner) internal view returns (uint) {
        return _slotDatum[_slot].balanceOf[_owner];
    }

    function _slotCurrentSupply(uint _slot) internal view returns (uint) {
        return _slotDatum[_slot].currentSupply;
    }

    function transferFromSlot(
        uint _fromIndex,
        uint _toIndex,
        uint _slot,
        uint _value
    ) public payable virtual override {
        require(_fromIndex != 0, "ERC3525: from index cannot be zero");
        require(_toIndex != 0, "ERC3525: to index cannot be zero");

        SlotData storage data = _slotDatum[_slot];
        uint fromTokenId = data.indexToTokenId[_fromIndex];
        uint toTokenId = data.indexToTokenId[_toIndex];

        ERC3525Upgradeable.transferFrom(fromTokenId, toTokenId, _value);
    }
    
    function transferFromSlot(
        uint _fromIndex,
        address _to,
        uint _slot,
        uint _value
    ) public payable virtual override returns (uint) {
        require(_fromIndex != 0, "ERC3525: from index cannot be zero");

        SlotData storage data = _slotDatum[_slot];
        uint fromTokenId = data.indexToTokenId[_fromIndex];

        return ERC3525Upgradeable.transferFrom(fromTokenId, _to, _value);
    }

    function transferFromSlot(
        address _from,
        address _to,
        uint _index,
        uint _slot
    ) public payable virtual override {
        require(_index != 0, "ERC3525: from index cannot be zero");

        SlotData storage data = _slotDatum[_slot];
        uint tokenId = data.indexToTokenId[_index];

        ERC3525Upgradeable.transferFrom(_from, _to, tokenId);
    }

    function safeTransferFromSlot(
        address _from,
        address _to,
        uint _index,
        uint _slot,
        bytes memory _data
    ) public payable virtual override {
        require(_index != 0, "ERC3525: from index cannot be zero");

        SlotData storage data = _slotDatum[_slot];
        uint tokenId = data.indexToTokenId[_index];

        ERC3525Upgradeable.safeTransferFrom(_from, _to, tokenId, _data);
    }

    function safeTransferFromSlot(
        address _from,
        address _to,
        uint _index,
        uint _slot
    ) public payable virtual override {
        require(_index != 0, "ERC3525: from index cannot be zero");

        SlotData storage data = _slotDatum[_slot];
        uint tokenId = data.indexToTokenId[_index];

        ERC3525Upgradeable.safeTransferFrom(_from, _to, tokenId);
    }
    
    function slotURI(uint256 slot_) public view override returns (string memory) {
        string memory baseURI = _baseURI();
        address desc = _slotDescriptor[slot_];
        return 
            desc != address(0) ? 
                IERC3525MetadataDescriptorUpgradeable(desc).constructSlotURI(slot_) : 
                bytes(baseURI).length > 0 ? 
                    string(abi.encodePacked(baseURI, "slot/", slot_.toString())) : 
                    "";
    }

    function tokenURI(uint256 tokenId_) public view  override returns (string memory) {
        _requireMinted(tokenId_);
        string memory baseURI = _baseURI();
        uint256 slot = ERC3525Upgradeable.slotOf(tokenId_);
        address desc = _slotDescriptor[slot];
        return 
            desc != address(0) ? 
                IERC3525MetadataDescriptorUpgradeable(desc).constructTokenURI(tokenId_) : 
                bytes(baseURI).length > 0 ? 
                    string(abi.encodePacked(baseURI, tokenId_.toString())) : 
                    "";
    }

    function _updateSlotDescriptor(uint _slot, address _addr) internal {
        _slotDescriptor[_slot] = _addr;
        _slotExists[_slot] = true;
    }

    function _isSlotExists(uint _slot) internal view returns (bool) {
        return _slotExists[_slot];
    }

    function _beforeValueTransfer(
        address from_,
        address to_,
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 slot_,
        uint256 value_
    ) internal virtual override {

        if (fromTokenId_ == 0) {
            if (_slotFirstToken[to_][slot_] == 0) {
                _slotFirstToken[to_][slot_] = toTokenId_;
            }

            _slotDatum[slot_].currentSupply += value_;
            return;
        }

        if (toTokenId_ == 0) {
            if (_slotFirstToken[to_][slot_] == fromTokenId_) {
                delete _slotFirstToken[to_][slot_];
            }

            _slotDatum[slot_].currentSupply -= value_;
            return;
        }

        if (from_ != to_ && fromTokenId_ == toTokenId_) {
            if (_slotFirstToken[from_][slot_] == fromTokenId_) {
                delete _slotFirstToken[from_][slot_];
            }
            if (_slotFirstToken[to_][slot_] == 0) {
                _slotFirstToken[to_][slot_] = fromTokenId_;
            }
        }
    }

    function _afterValueTransfer(
        address from_,
        address to_,
        uint256 fromTokenId_,
        uint256 toTokenId_,
        uint256 slot_,
        uint256 value_
    ) internal virtual override {
        value_;
        
        if (fromTokenId_ == 0) {
            SlotData storage data = _slotDatum[slot_];
            data.counter.increment();
            uint index = data.counter.current();
            data.tokenIdToIndex[toTokenId_] = index;
            data.indexToTokenId[index] = toTokenId_;
            data.indexToOwner[index] = to_;
            data.balanceOf[to_] = data.balanceOf[to_] + 1;
            return;
        }

        if (from_ != to_ && fromTokenId_ == toTokenId_) {
            SlotData storage data = _slotDatum[slot_];
            uint index = data.tokenIdToIndex[fromTokenId_];
            data.indexToOwner[index] = to_;
            data.balanceOf[from_] = data.balanceOf[from_] - 1;
            data.balanceOf[to_] = data.balanceOf[to_] + 1;
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}