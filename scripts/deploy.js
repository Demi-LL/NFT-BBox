require('dotenv').config();
const { ethers } = require("hardhat");

async function main() {
    const BBox = await ethers.getContractFactory("BBox");
    const contract = await BBox.deploy("BBOX", "BOX");

    console.log("BBOX deployed to:", contract.address);
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});
