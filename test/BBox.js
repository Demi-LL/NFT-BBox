const { expect } = require("chai");
const { ethers } = require("hardhat");

async function deployedContract() {
  const BBox = await ethers.getContractFactory("BBox");
  const contract = await BBox.deploy("BBOX", "BOX");
  await contract.deployed();

  return contract;
}

let contract;
describe("BBox", function () {
  beforeEach(async function() {
    contract = await deployedContract();
  });

  describe("Metadata", function () {
    it("Should return 0", async function () {
      expect(await contract.totalSupply()).to.equal(0);
    });

    it("Should return BBOX", async function () {
      expect(await contract.name()).to.equal("BBOX");
    });

    it("Should return BOX", async function () {
      expect(await contract.symbol()).to.equal("BOX");
    });
  });

  describe("Owner", function () {
    let owner;
    let account1;

    beforeEach(async function() {
      [owner, account1] = await ethers.getSigners();
      await contract.connect(owner);
    });

    /**
    * TODO: find methods to catch require, revert error when call contract
    */
    describe("Not action yet", function () {
      it ("Should return 0", async function () {
        expect(await contract.balanceOf(owner.address)).to.equal(0);
      });

      it("Should return 1 after mintNFT()", async function () {
        await contract.setOpeningMax(1);
        await contract.setPurchaseStatus(true);
        await contract.mintNFT();

        expect(await contract.balanceOf(owner.address)).to.equal(1);
      });

      it("Should return 1 after airdrop()", async function () {
        await contract.setOpeningMax(1);
        await contract.setPurchaseStatus(true);
        await contract.airdrop(account1.address, 1);

        expect(await contract.balanceOf(owner.address)).to.equal(0);
        expect(await contract.balanceOf(account1.address)).to.equal(1);
      });
    });
  });
});
