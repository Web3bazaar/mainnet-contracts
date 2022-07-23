const Web3BazaarBatch = artifacts.require("Web3BazaarEscrow");
const Bazcoin = artifacts.require("Bazcoin");
const TestCollection = artifacts.require("TestCollection");
const BazaarERC1155Collection = artifacts.require("BazaarERC1155Collection");

const web3 = require("web3");

contract(
  "Web3BazaarBatch - MultiAccessControl admin functions",
  async (accounts) => {
    it("Should throw an error NOT_ADMIN ", async () => {
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

      try {
        await BazaarEscrowInstance.addOwnership(accounts[1], {
          from: accounts[1],
        });
      } catch (error) {
        const isReverting = error.message.search("ERR_NOT_OWNER") >= 0;
        assert.equal(
          isReverting,
          true,
          "Should'nt be able to add yourself as admin"
        );
        return;
      }
      assert.fail("Expected throw not received");
    });
    it("remove an admin without being admin", async () => {
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

      try {
        await BazaarEscrowInstance.removeOwnership(accounts[1], {
          from: accounts[0],
        });
      } catch (error) {
        const isReverting = error.message.search("ERR_ADDR_NOT_OWNER") >= 0;
        assert.equal(
          isReverting,
          true,
          "Should'nt be able to add yourself as admin"
        );
        return;
      }
      assert.fail("Expected throw not received");
    });

    it("should add new admin", async () => {
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

      try {
        await BazaarEscrowInstance.addOwnership(accounts[1], {
          from: accounts[0],
        });
        await BazaarEscrowInstance.removeOwnership(accounts[1], {
          from: accounts[0],
        });
      } catch (error) {
        assert.fail(
          "Not expected throw and error for adding and removing ownership"
        );
        return;
      }
      assert.ok(true);
    });
  }
);
