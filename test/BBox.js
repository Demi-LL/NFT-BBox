const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BBox", function () {
  it("Should return DM", async function () {
    const BBox = await ethers.getContractFactory("BBox");
    const contract = await BBox.deploy();
    await contract.deployed();

    expect(await contract.hello()).to.equal("DM");
  });
});
