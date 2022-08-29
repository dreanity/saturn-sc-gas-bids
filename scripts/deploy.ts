import { ethers, upgrades } from "hardhat";

async function main() {
  const [ deployer ] = await ethers.getSigners();

  const GasBidsFactory = await ethers.getContractFactory("GasBids_V0");
  const gasBids = await upgrades.deployProxy(GasBidsFactory, [], {
    initializer: 'initialize',
  });

  await gasBids.deployed()

  return { gasBids, deployer }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
