import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';
import { ethers, upgrades } from 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signer-with-address';
import { GasBids_V0, USDTToken } from '../typechain-types';

interface DepType {
	gasBids: GasBids_V0;
	usdtToken: USDTToken;
	deployer: SignerWithAddress;
	acc2: SignerWithAddress;
}

describe("Upgradeble GasBid", function() {
	async function dep(): Promise<DepType> {
		const [deployer, acc2] = await ethers.getSigners();


		const GasBidsFactory = await ethers.getContractFactory("GasBids_V0");
		const gasBids = await upgrades.deployProxy(GasBidsFactory, [], {
			initializer: 'initialize',
			kind: 'uups',
		}) as GasBids_V0;

		await gasBids.deployed()

		const USDTToken = await ethers.getContractFactory("USDTToken", acc2);
		const usdtToken = await USDTToken.deploy(1000) as USDTToken;

		await usdtToken.deployed()

		return { gasBids, usdtToken, deployer, acc2 }
	}

	it("should be deployed", async function () {
		const { gasBids, usdtToken } = await loadFixture(dep)
		expect(gasBids.address).to.be.properAddress
		expect(usdtToken.address).to.be.properAddress
	})

	it("crediting the balance USDT and creating bid", async function () {
		const sum = 500;
		const recipientAddr = "cosmosfdfsfsdfadf332"

		const { gasBids, usdtToken, acc2 } = await loadFixture(dep)
		const approve = await usdtToken.approve(gasBids.address, sum, { from: acc2.address})
		await approve.wait()

		const createBid = await gasBids.connect(acc2).createBid(usdtToken.address, recipientAddr)
		await createBid.wait();

		expect(await usdtToken.balanceOf(gasBids.address)).to.eq(sum)
		const bid = await gasBids.bids(0)
		expect(bid.paymentTokenAddr).to.eq(usdtToken.address)
		expect(bid.paymentAmount).to.eq(sum)
		expect(bid.recipientAddr).to.eq(recipientAddr)
	})

	it("get bids counter", async function () {
		const { gasBids, usdtToken } = await loadFixture(dep)
		expect(await gasBids.getBidsCounter()).to.eq(0)
	})
})