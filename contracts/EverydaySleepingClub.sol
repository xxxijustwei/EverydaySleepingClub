// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.17;

import "@solvprotocol/erc-3525/periphery/interface/IERC3525MetadataDescriptor.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "./extend/ERC3525Extended.sol";
import "./interfaces/voucher/IPlayground.sol";
import "./interfaces/lottery/IGameFacet.sol";
import "./interfaces/lottery/IAdminFacet.sol";

contract EverydaySleepingClub is IPlayground, ERC3525Extended, Ownable {

    mapping(uint => address) public games;
    mapping(uint => bool) public enable;
    mapping(uint => uint) public slotTotalSupply;
    mapping(uint => uint) public sharesPool;
    mapping(uint => uint) public totalDividend;
    mapping(uint => uint) public dividendPool;
    mapping(address => mapping(uint => uint)) public claimedDividend;

    modifier isSlotExists(uint _slot) {
        require(ERC3525Extended._isSlotExists(_slot), "ESC: slot does not exist");
        _;
    }

    modifier canPlay(uint _slot) {
        require(enable[_slot], "ESC: game paused");
        _;
    }

    constructor() ERC3525Extended("EverydaySleepingClub", "ESC", 6) {}

    function play(address _to, uint _slot, uint _count) external payable isSlotExists(_slot) canPlay(_slot) {
        IGameFacet game = IGameFacet(games[_slot]);
        IERC20 currency = IERC20(game.currency());

        uint256 payin = game.price() * _count;
        uint capital = payin / 100 * game.voucherRatio();
        currency.transferFrom(_msgSender(), address(this), payin);
        currency.transfer(games[_slot], payin - capital);

        sharesPool[_slot] += capital;

        (bool ok, bytes memory data) = games[_slot].call{value: msg.value, gas: 30000}(
            abi.encodeWithSignature("play(address,uint256)", _to, _count)
        );
        require(ok);

        if (ERC3525Extended._slotCurrentSupply(_slot) < slotTotalSupply[_slot]) {
            uint amount = abi.decode(data, (uint256));
            amount = _mintValue(_to, _slot, amount);
            emit UserMintShares(_to, _slot, amount);
        }
    }

    function burn(uint _slot, uint _amount) external isSlotExists(_slot) {
        uint payout = _calculateSharesValue(_slot, _amount);
        _burnValue(_msgSender(), _slot, _amount);
        emit UserBurnShares(_msgSender(), _slot, _amount, payout);

        IGameFacet game = IGameFacet(games[_slot]);
        IERC20 currency = IERC20(game.currency());
        require(currency.balanceOf(address(this)) >= payout, "burn failed");

        sharesPool[_slot] -= payout;
        currency.transfer(_msgSender(), payout);
    }

    function addDividendPool(uint _slot, uint _amount) external isSlotExists(_slot) {
        if (_amount == 0) return;

        IERC20 currency = IERC20(IGameFacet(games[_slot]).currency());

        totalDividend[_slot] += _amount;
        dividendPool[_slot] += _amount;
        currency.transferFrom(_msgSender(), address(this), _amount);

        emit DividendPoolChange(_slot, totalDividend[_slot], dividendPool[_slot], _amount);
    }

    function claimDividend(uint _slot) external isSlotExists(_slot) {
        IERC20 currency = IERC20(IGameFacet(games[_slot]).currency());

        uint value = _userDividendValue(_msgSender(), _slot);
        uint pool = dividendPool[_slot];
        if (value > pool) value = pool;

        dividendPool[_slot] -= value;
        claimedDividend[_msgSender()][_slot] += value;
        currency.transfer(_msgSender(), value);

        emit UserClaimDividend(_msgSender(), _slot, value);
    }

    function setEnable(uint _slot, bool _off) external onlyOwner isSlotExists(_slot) {
        enable[_slot] = _off;
    }
    
    function isEnable(uint _slot) external view onlyOwner isSlotExists(_slot) returns (bool) {
        return enable[_slot];
    }

    function registerGame(uint _slot, address _game, uint _sharesFunds) external onlyOwner {
        require(games[_slot] == address(0), "ESC: slot registered");
        require(_game != address(0), "ESC: game address cannot be zero");

        IGameFacet game = IGameFacet(_game);
        games[_slot] = _game;
        slotTotalSupply[_slot] = game.valuesTotalSupply() * 10**ERC3525.valueDecimals();

        IERC20 currency = IERC20(game.currency());
        currency.transferFrom(_msgSender(), address(this), _sharesFunds);
        _mintValue(_game, _slot, game.premitQuantity() * 10**ERC3525.valueDecimals());
        sharesPool[_slot] += _sharesFunds;
    }

    function getUserSharesValue(address _user, uint _slot) external view returns (uint) {
        return _userSharesValue(_user, _slot);
    }

    function getUserDividendValue(address _user, uint _slot) external view returns (uint) {
        return _userDividendValue(_user, _slot);
    }

    function setSFTDescriptor(address _addr) external onlyOwner {
        require(_addr != address(0), "ESC: descriptor address cannot be zero");
        ERC3525._setMetadataDescriptor(_addr);
    }

    function setSlotDescriptor(uint _slot, address _addr) external onlyOwner {
        require(_addr != address(0), "ESC: descriptor address cannot be zero");
        ERC3525Extended._updateSlotDescriptor(_slot, _addr);
    }

    function _mintValue(address _to, uint _slot, uint _value) internal returns (uint) {
        uint tokenId = ERC3525Extended.getUserFirstTokenIdInSlot(_to, _slot);
        uint currentSupply = ERC3525Extended._slotCurrentSupply(_slot);
        uint totalSupply = slotTotalSupply[_slot];
        if (currentSupply + _value > totalSupply) _value = totalSupply - currentSupply;

        if (tokenId == 0) {
            ERC3525._mint(_to, _slot, _value);
        } else {
            ERC3525._mintValue(tokenId, _value);
        }

        return _value;
    }

    function _burnValue(address _to, uint _slot, uint _value) internal {
        require(_value != 0, "ESC: value cannot be zero");
        uint tokenId = ERC3525Extended.getUserFirstTokenIdInSlot(_to, _slot);

        ERC3525._burnValue(tokenId, _value);
    }

    function _userSharesValue(address _user, uint _slot) internal view returns (uint) {
        uint tokenId = ERC3525Extended._userFirstTokenIdInSlot(_user, _slot);
        return _calculateSharesValue(_slot, ERC3525.balanceOf(tokenId));
    }

    function _calculateSharesValue(uint _slot, uint _amount) internal view returns (uint) {
        return _amount * sharesPool[_slot] / ERC3525Extended._slotCurrentSupply(_slot);
    }

    function _userDividendValue(address _user, uint _slot) internal view returns (uint) {
        uint tokenId = ERC3525Extended._userFirstTokenIdInSlot(_user, _slot);
        uint claimed = claimedDividend[_user][_slot];
        uint value = _calculateDividendValue(_slot, ERC3525.balanceOf(tokenId));
        if (claimed >= value) return 0;
        return value - claimed;
    }

    function _calculateDividendValue(uint _slot, uint _amount) internal view returns (uint) {
        return _amount * totalDividend[_slot] / ERC3525Extended._slotCurrentSupply(_slot);
    }
}