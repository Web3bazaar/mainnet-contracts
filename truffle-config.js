const HDWalletProvider = require("@truffle/hdwallet-provider");
require("dotenv").config();
const fs = require("fs");
const privKey = fs.readFileSync(".privkey").toString().trim();
// https://ethereum.stackexchange.com/questions/102302/unable-to-connect-to-polygon-mumbai-test-network-using-truffle

module.exports = {
  // Uncommenting the defaults below
  // provides for an easier quick-start with Ganache.
  // You can also follow this format for other networks.
  // See details at: https://trufflesuite.com/docs/truffle/reference/configuration
  // on how to specify configuration options!
  //
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
    },
    mumbai: {
      provider: () =>
        new HDWalletProvider(
          privKey,
          "https://rpc-mumbai.maticvigil.com/v1/b22946af83eb7e2498773672df08b8216e60aa07"
        ),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
    matic: {
      provider: () =>
        new HDWalletProvider(
          privKey,
          "https://rpc-mainnet.maticvigil.com/v1/b22946af83eb7e2498773672df08b8216e60aa07"
        ),
      gasPrice: 6001928,
      network_id: 137,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
  },
  //
  // Truffle DB is currently disabled by default; to enable it, change enabled:
  // false to enabled: true. The default storage location can also be
  // overridden by specifying the adapter settings, as shown in the commented code below.
  //
  // NOTE: It is not possible to migrate your contracts to truffle DB and you should
  // make a backup of your artifacts to a safe location before enabling this feature.
  //
  // After you backed up your artifacts you can utilize db by running migrate as follows:
  // $ truffle migrate --reset --compile-all
  //
  // db: {
  // enabled: false,
  // host: "127.0.0.1",
  // adapter: {
  //   name: "sqlite",
  //   settings: {
  //     directory: ".db"
  //   }
  // }
  // }
  compilers: {
    solc: {
      version: "0.8.14", // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {
        // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 400,
        },
        evmVersion: "byzantium",
      },
    },
  },

  plugins: ["solidity-coverage", "truffle-plugin-verify"],
  api_keys: {
    etherscan: "",
    polygonscan: process.env.MUMBAI_API_KEY,
  },
};
