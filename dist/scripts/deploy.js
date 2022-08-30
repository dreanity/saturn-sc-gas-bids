"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const hardhat_1 = require("hardhat");
async function main() {
    const [deployer] = await hardhat_1.ethers.getSigners();
    const GasBidsFactory = await hardhat_1.ethers.getContractFactory("GasBids_V0");
    const gasBids = await hardhat_1.upgrades.deployProxy(GasBidsFactory, [], {
        initializer: 'initialize',
        kind: 'uups',
    });
    await gasBids.deployed();
    return { gasBids, deployer };
}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
