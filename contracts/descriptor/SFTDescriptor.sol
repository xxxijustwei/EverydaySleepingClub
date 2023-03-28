//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "@solvprotocol/erc-3525/periphery/ERC3525MetadataDescriptor.sol";
import "@solvprotocol/erc-3525/extensions/IERC3525Metadata.sol";

contract SFTDescriptor is ERC3525MetadataDescriptor {

    using Strings for uint256;

    function _contractDescription() internal pure override returns (string memory) {
        return 
            "I want to be part of the Everyday Sleep Club";
    }

    function _contractImage() internal pure override returns (bytes memory) {
        return "ipfs://QmX5tTToNmpACVCk7VrRx1D8GQwrzgYnQFVcahGfUhxTfp";
    }
}