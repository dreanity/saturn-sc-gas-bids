// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Extented is IERC20 {
    function decimals() external view returns (uint8);
}

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract GasBids_V0 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    struct Bid {
        address paymentTokenAddr;
        uint8 paymentTokenScale;
        uint256 paymentAmount;
        string recipientAddr;
    }

    CountersUpgradeable.Counter private bidsCounter;
    mapping(uint256 => Bid) public bids;

    event BidCreated(
        uint256 index,
        address paymentTokenAddr,
        uint8 paymentTokenScale,
        uint256 paymentAmount,
        string recipientAddr
    );

    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function createBid(address paymentTokenAddr, string calldata recipientAddr)
        public
        returns (bool)
    {
        require(
            AddressUpgradeable.isContract(paymentTokenAddr),
            "paymentTokenAddr should point to a smart contract"
        );

        IERC20Extented paymentToken = IERC20Extented(paymentTokenAddr);

        address addrOfThis = address(this);
        address sender = _msgSender();
        uint256 allowance = paymentToken.allowance(sender, addrOfThis);
        require(allowance > 0, "allowance must be greater than 0");
        require(
            paymentToken.transferFrom(sender, addrOfThis, allowance),
            "transfer from failed"
        );

        uint8 paymentTokenScale = paymentToken.decimals();

        Bid memory bid = Bid({
            paymentTokenAddr: paymentTokenAddr,
            paymentTokenScale: paymentTokenScale,
            paymentAmount: allowance,
            recipientAddr: recipientAddr
        });

        emit BidCreated(
            bidsCounter.current(),
            paymentTokenAddr,
            paymentTokenScale,
            allowance,
            recipientAddr
        );

        bids[bidsCounter.current()] = bid;
        bidsCounter.increment();

        return true;
    }

    function getBidsCounter() public view returns (uint256) {
        return bidsCounter.current();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    function getBalanceContract() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    function withdraw(uint256 _amount) public onlyOwner returns (bool) {
        require(_amount > address(this).balance, "Insufficient funds");
        payable(_msgSender()).transfer(_amount);
        return true;
    }

    function withdrawTo(uint256 _amount, address _to)
        public
        onlyOwner
        returns (bool)
    {
        require(_amount > address(this).balance, "Insufficient funds");
        payable(_to).transfer(_amount);
        return true;
    }

    function withdrawToken(address _tokenContract, uint256 _amount)
        external
        onlyOwner
        returns (bool)
    {
        IERC20 tokenContract = IERC20(_tokenContract);
        require(
            _amount > tokenContract.balanceOf(address(this)),
            "Insufficient funds"
        );

        tokenContract.transfer(_msgSender(), _amount);
        return true;
    }

    function withdrawTokenTo(
        address _tokenContract,
        uint256 _amount,
        address _to
    ) external onlyOwner returns (bool) {
        IERC20 tokenContract = IERC20(_tokenContract);
        require(
            _amount > tokenContract.balanceOf(address(this)),
            "Insufficient funds"
        );

        tokenContract.transfer(_to, _amount);
        return true;
    }

    function withdrawAllToken(address _tokenContract)
        external
        onlyOwner
        returns (bool)
    {
        IERC20 tokenContract = IERC20(_tokenContract);

        tokenContract.transfer(
            _msgSender(),
            tokenContract.balanceOf(address(this))
        );
        return true;
    }

    receive() external payable {}
}
