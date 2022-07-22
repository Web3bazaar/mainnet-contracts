
const Web3BazaarEscrow = artifacts.require("Web3BazaarEscrow");
const Bazcoin = artifacts.require("Bazcoin");
const TestCollection = artifacts.require("TestCollection");


module.exports = function(deployer) {
  deployer.deploy(Web3BazaarEscrow);
  deployer.deploy(Bazcoin);
  deployer.deploy(TestCollection);
};
