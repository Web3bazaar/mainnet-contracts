const BazaarRaffleTicket = artifacts.require("BazaarRaffleTicket");

module.exports = function (deployer) {
  deployer.deploy(BazaarRaffleTicket);
};
