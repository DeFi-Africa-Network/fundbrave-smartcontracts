// scripts/deploy.js
const { ethers } = require('hardhat');

async function main() {
  // Deploy Crowdfunding contract
  const Crowdfunding = await ethers.getContractFactory('Crowdfunding');
  const crowdfunding = await Crowdfunding.deploy();
  await crowdfunding.deployed();
  console.log('Crowdfunding contract deployed to:', crowdfunding.address);

  // Deploy Project contract
  const Project = await ethers.getContractFactory('Project');
  const project = await Project.deploy(/* constructor parameters if any */);
  await project.deployed();
  console.log('Project contract deployed to:', project.address);

}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
