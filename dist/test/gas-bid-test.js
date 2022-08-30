"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const hardhat_network_helpers_1 = require("@nomicfoundation/hardhat-network-helpers");
const chai_1 = require("chai");
const hardhat_1 = require("hardhat");
describe("Upgradeble GasBid", function () {
    async function dep() {
        const [deployer, acc2] = await hardhat_1.ethers.getSigners();
        const GasBidsFactory = await hardhat_1.ethers.getContractFactory("GasBids_V0");
        const gasBids = await hardhat_1.upgrades.deployProxy(GasBidsFactory, [], {
            initializer: 'initialize',
            kind: 'uups',
        });
        await gasBids.deployed();
        const USDTToken = await hardhat_1.ethers.getContractFactory("USDTToken", acc2);
        const usdtToken = await USDTToken.deploy(1000);
        await usdtToken.deployed();
        return { gasBids, usdtToken, deployer, acc2 };
    }
    it("should be deployed", async function () {
        const { gasBids, usdtToken } = await (0, hardhat_network_helpers_1.loadFixture)(dep);
        (0, chai_1.expect)(gasBids.address).to.be.properAddress;
        (0, chai_1.expect)(usdtToken.address).to.be.properAddress;
    });
    it("crediting the balance USDT and creating bid", async function () {
        const sum = 500;
        const recipientAddr = "cosmosfdfsfsdfadf332";
        const { gasBids, usdtToken, acc2 } = await (0, hardhat_network_helpers_1.loadFixture)(dep);
        const approve = await usdtToken.approve(gasBids.address, sum, { from: acc2.address });
        await approve.wait();
        const createBid = await gasBids.connect(acc2).createBid(usdtToken.address, recipientAddr);
        await createBid.wait();
        (0, chai_1.expect)(await usdtToken.balanceOf(gasBids.address)).to.eq(sum);
        const bid = await gasBids.bids(0);
        (0, chai_1.expect)(bid.paymentTokenAddr).to.eq(usdtToken.address);
        (0, chai_1.expect)(bid.paymentAmount).to.eq(sum);
        (0, chai_1.expect)(bid.recipientAddr).to.eq(recipientAddr);
    });
});
