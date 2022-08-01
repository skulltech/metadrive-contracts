import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { randomBytes } from "crypto";

describe("MetadriveFile", () => {
  const deployContract = async () => {
    const [owner, otherAccount] = await ethers.getSigners();

    const MetadriveFile = await ethers.getContractFactory("MetadriveFile");
    const metadriveFile = await MetadriveFile.deploy();
    await metadriveFile.deployed();

    return { metadriveFile, owner, otherAccount };
  };

  describe("Deploying the contract", () => {
    it("can set the correct token name and symbol", async () => {
      const { metadriveFile } = await loadFixture(deployContract);

      expect(await metadriveFile.name()).to.equal("MetadriveFile");
      expect(await metadriveFile.symbol()).to.equal("MDF");
    });
  });

  describe("Registering an address", () => {
    it("can register an address", async () => {
      const { metadriveFile, otherAccount } = await loadFixture(deployContract);

      // Ensure publicKey is not set before registering
      expect(await metadriveFile.publicKeys(otherAccount.address)).to.equal(
        ethers.constants.HashZero
      );

      // Register and ensure event emits
      const publicKey = randomBytes(32);
      await expect(metadriveFile.connect(otherAccount).register(publicKey))
        .to.emit(metadriveFile, "Register")
        .withArgs(otherAccount.address, otherAccount.address, publicKey);

      // Ensure publicKey is set correctly after registering
      expect(await metadriveFile.publicKeys(otherAccount.address)).to.equal(
        "0x" + publicKey.toString("hex")
      );
    });
  });
});
