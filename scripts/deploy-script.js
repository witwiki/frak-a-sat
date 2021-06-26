// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile 
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // // We get the contract to deploy
  // const Greeter = await hre.ethers.getContractFactory("Greeter");
  // const greeter = await Greeter.deploy("Hello, Hardhat!");
  // await greeter.deployed();
  // console.log("Greeter deployed to:", greeter.address);

  // Deploy FrakMarket.sol
  const FrakMarket = await hre.ethers.getContractFactory("FrakMarket");
  const frakMarket = await FrakMarket.deploy();
  await frakMarket.deployed();
  console.log("frakMarket deployed to: ", frakMarket.address);

  // Deploy FrakSat.sol  
  const FrakedSat = await hre.ethers.getContractFactory("FrakedSat");
  const frakedSat = await FrakedSat.deploy(frakMarket.address);
  await frakedSat.deployed();
  console.log("frakedSat deployed to: ", frakedSat.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
