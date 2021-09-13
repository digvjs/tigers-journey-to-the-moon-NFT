const TJTTM = artifacts.require("TJTTM");
const TJTTMSales = artifacts.require("TJTTMSales");
const TJTTMAirdrop = artifacts.require("TJTTMAirdrop");

const SALE_START_TIME = 123   // epoch time

module.exports = async function (deployer) {

  // Token deploy
  await deployer.deploy(TJTTM);
  const deployedTJTTM = await TJTTM.deployed();

  // Sales contract deploy
  const _tokenAddress = deployedTJTTM.address;
  await deployer.deploy(TJTTMSales, _tokenAddress, SALE_START_TIME);
  const deployedSalesContract = await TJTTMSales.deployed();

  // Airdrop contract deploy
  await deployer.deploy(TJTTMAirdrop);
  const deployedAirdropContract = await TJTTMAirdrop.deployed();


  // Operations post deployment

  // 1. Approval to airdrop contract
  await deployedTJTTM.setApprovalForAll(deployedAirdropContract.address, true);

  // 2. Ownership to sale contract

};

