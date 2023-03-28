//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "@solvprotocol/erc-3525/periphery/interface/IERC3525MetadataDescriptor.sol";
import "@solvprotocol/erc-3525/extensions/IERC3525Metadata.sol";

import "../interfaces/IERC3525ExtendedUpgradeable.sol";
import "./Samoyed.sol";

contract SamoyedDescriptor is IERC3525MetadataDescriptor {

    using Strings for uint256;

    function constructContractURI() external pure override returns (string memory) {
        return "";
    }

    function constructSlotURI(uint256 slot_) external pure override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    /* solhint-disable */
                    'data:application/json;base64,',
                    Base64.encode(
                        abi.encodePacked(
                            '{"name":"', 
                            _slotName(slot_),
                            '","description":"',
                            _slotDescription(slot_),
                            '","image":"',
                            _slotImage(slot_),
                            '","properties":',
                            _slotProperties(slot_),
                            '}'
                        )
                    )
                    /* solhint-enable */
                )
            );
    }

    function constructTokenURI(uint256 tokenId_) external view override returns (string memory) {
        IERC3525Metadata erc3525 = IERC3525Metadata(msg.sender);
        uint index = IERC3525ExtendedUpgradeable(msg.sender).getTokenIndexInSlot(tokenId_);
        return 
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            /* solhint-disable */
                            '{"name":"',
                            _tokenName(index),
                            '","description":"',
                            _description(),
                            '","image_data":"',
                            Samoyed.render(index),
                            '","balance":"',
                            erc3525.balanceOf(tokenId_).toString(),
                            '","slot":"',
                            erc3525.slotOf(tokenId_).toString(),
                            '","properties":',
                            _tokenProperties(tokenId_),
                            "}"
                            /* solhint-enable */
                        )
                    )
                )
            );
    }

    function _name() internal pure returns (string memory) {
        return "Samoyed";
    }

    function _description() internal pure returns (string memory) {
        return "Just samoyed!";
    }

    function _slotName(uint256 slot_) internal pure returns (string memory) {
        slot_;
        return "Samoyed";
    }

    function _slotDescription(uint256 slot_) internal pure returns (string memory) {
        slot_;
        return _description();
    }

    function _slotImage(uint256 slot_) internal pure returns (bytes memory) {
        slot_;
        return "";
    }

    function _slotProperties(uint256 slot_) internal pure returns (string memory) {
        slot_;
        return "[]";
    }

    function _tokenName(uint256 tokenId_) internal pure returns (string memory) {
        // solhint-disable-next-line
        return 
            string(
                abi.encodePacked(
                    _name(), 
                    " #", tokenId_.toString()
                )
            );
    }

    function _tokenProperties(uint256 tokenId_) internal pure returns (string memory) {
        tokenId_;
        return "{}";
    }

}