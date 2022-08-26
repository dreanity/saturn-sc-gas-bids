// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract GasBids_V0 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    struct Bid {
        address paymentTokenAddr;
        uint256 paymentAmount;
        string recipientAddr;
    }

    CountersUpgradeable.Counter private bidsCounter;
    mapping(uint256 => Bid) public bids;
    mapping(address => uint256) public balances;

    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function createBid(address paymentTokenAddr, string calldata recipientAddr)
        public
    {
        address sender = _msgSender();

        IERC20 paymentToken = IERC20(paymentTokenAddr);

        uint256 allowance = paymentToken.allowance(sender, address(this));
        require(allowance > 0, "allowance must be greater than 0");

        Bid memory bid = Bid({
            paymentTokenAddr: paymentTokenAddr,
            paymentAmount: allowance,
            recipientAddr: recipientAddr
        });

        bids[bidsCounter.current()] = bid;
        bidsCounter.increment();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    receive() external payable {
        balances[msg.sender] += msg.value;
    }
}
