// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "@solvprotocol/erc-3525/ERC3525.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import {AppStorage} from "../AppStorage.sol";

contract AirdropFacet {

    AppStorage s;

    error AirdropOnlyClaimOnce();
    error NotEligible();

    function claim(uint256 _quantity, bytes32[] calldata merkleProof)
        external
    {
        if (s.claim[msg.sender]) revert AirdropOnlyClaimOnce();
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _quantity));
        if (!MerkleProof.verify(merkleProof, _root(), leaf)) revert NotEligible();

        s.claim[msg.sender] = true;

        IERC3525 sft = IERC3525(s.voucher);
        sft.transferFrom(1, msg.sender, _quantity);
    }

    function _root() internal pure returns (bytes32) {
        return 0x933541ec91e721841516789f142b145bcfd742dc5dc2752d791ad49454355e52;
    }
}