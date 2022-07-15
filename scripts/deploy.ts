import { ethers } from "hardhat";

async function main() {
  const MetadriveFile = await ethers.getContractFactory("MetadriveFile");
  const metadriveFile = await MetadriveFile.deploy();
  await metadriveFile.deployed();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
