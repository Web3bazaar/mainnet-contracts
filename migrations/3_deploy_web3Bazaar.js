const Web3BazaarEscrow = artifacts.require("Web3BazaarEscrow");

module.exports = function (deployer) {
  deployer.deploy(Web3BazaarEscrow);
};
