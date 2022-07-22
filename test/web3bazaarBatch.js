const Web3BazaarBatch = artifacts.require("Web3BazaarEscrow");
const Bazcoin = artifacts.require("Bazcoin");
const TestCollection = artifacts.require("TestCollection");
const web3 = require("web3");
const truffleAssert = require("truffle-assertions");

// https://www.youtube.com/watch?v=PeiTfWN7Ik0

contract("Web3BazaarBatch Contract ", async (accounts) => {
  const WALLET_ADMIN = accounts[0];
  const WALLET_ONE = accounts[1];
  const WALLET_TWO = accounts[2];

  it("Mint ERC20 tokens for Wallet One", async () => {
    const BazcoinInstance = await Bazcoin.deployed();
    // console.log('bazcoin conctract address: ', BazcoinInstance.address );
    const assertBalance = 50e18;
    await BazcoinInstance.mint({ from: WALLET_ONE });
    let twoBalance = await BazcoinInstance.balanceOf(WALLET_ONE);
    let toNumber = web3.utils.toBN(twoBalance);
    // console.log('balance two: ', toNumber.toString())
    assert.equal(toNumber, assertBalance, "Balance should be " + assertBalance);
  });

  it("Mint ERC721 Itens for Wallet Two", async () => {
    const TestCollectionInstance = await TestCollection.deployed();
    //console.log('bazcoin conctract address: ', TestCollectionInstance.address );

    const MINT_IDS = [1, 2, 3, 4, 5];
    for await (idx of MINT_IDS) {
      await TestCollectionInstance.mint({ from: WALLET_TWO });
    }

    let nftsOwned = await TestCollectionInstance.balanceOf(WALLET_TWO);
    let toNumber = web3.utils.toBN(nftsOwned);
    //console.log('nft owned ', toNumber.toString() );
    assert.equal(MINT_IDS.length, toNumber, "should own 5 nfts");
  });

  it("Should read empty open trades", async () => {
    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
    const openTrades = await BazaarEscrowInstance.tradePerUser.call(WALLET_ONE);

    //  console.log('Bazaar Escrow Address : ', BazaarEscrowInstance.address );
    //console.log('openTrades : ', openTrades );
    assert.equal(
      openTrades.length,
      0,
      "Open trades for that wallet should be empty"
    );
  });

  it("Should return empty trade", async () => {
    const tradeId = 1;
    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
    const tradeInfo = await BazaarEscrowInstance.getTrade(1);
    //console.log('Trade Info ',  tradeInfo[0]);
    assert.equal(
      tradeInfo[0],
      0,
      "Open trades for that wallet should be empty"
    );
  });

  it("Wallet One allow web3Bazaar contract to send funds", async () => {
    const BazcoinInstance = await Bazcoin.deployed();
    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
    const allowanceLimit = 50e18;

    await BazcoinInstance.approve(
      BazaarEscrowInstance.address,
      web3.utils.toBN(allowanceLimit),
      {
        from: WALLET_ONE,
      }
    );

    let returnedAllowance = await BazcoinInstance.allowance(
      WALLET_ONE,
      BazaarEscrowInstance.address
    );
    //console.log("ReturnedAllowance : ", returnedAllowance);

    //console.log('Trade Info ',  tradeInfo[0]);
    assert.equal(
      returnedAllowance,
      allowanceLimit,
      "Open trades for that wallet should be empty"
    );
  });

  it("Initializate trade between Wallet 1 and Wallet 2 with sucess", async () => {
    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
    let bazCoinAddress = (await Bazcoin.deployed()).address;
    let erc721Address = (await TestCollection.deployed()).address;

    //console.log("bazCoinAddress : ", bazCoinAddress);
    //console.log("erc721Address : ", erc721Address);
    // console.log("to BigNumber ", web3.utils.toBN(40));

    const tradeId = await BazaarEscrowInstance.startTrade(
      [bazCoinAddress],
      [1],
      [web3.utils.toBN(40)],
      [1],
      //executer params
      WALLET_TWO,
      [
        erc721Address,
        erc721Address,
        erc721Address,
        erc721Address,
        erc721Address,
      ],
      [1, 2, 3, 4, 5],
      [1, 1, 1, 1, 1],
      [3, 3, 3, 3, 3],
      {
        from: WALLET_ONE,
      }
    );

    const openTrades = await BazaarEscrowInstance.tradePerUser.call(WALLET_ONE);

    //  console.log('Bazaar Escrow Address : ', BazaarEscrowInstance.address );
    //console.log('openTrades : ', openTrades );
    assert.equal(
      openTrades.length,
      1,
      "Open trades for wallet one should be 1"
    );
  });

  it("Execute trade should fail because wallet two wont allow web3bazaar contract to spend ERC721 tokens", async () => {
    const tradeId = 1;
    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

    try {
      await BazaarEscrowInstance.executeTrade(tradeId, {
        from: accounts[3],
      });
    } catch (error) {
      const isReverting =
        error.message.search("WEB3BAZAAR_ERROR: CALLER INST THE EXECUTER") >= 0;
      assert.equal(isReverting, true, "Should be able to excute trade");
      return;
    }
    assert.fail("Expected throw not received");
  });

  it("Try to complete a trade which not belon to wallet", async () => {
    const tradeId = 1;
    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

    try {
      await BazaarEscrowInstance.executeTrade(tradeId, {
        from: WALLET_TWO,
      });
    } catch (error) {
      const isReverting =
        error.message.search(
          "WEB3BAZAR_ERROR: ERR_NOT_ALLOW_TO_TRANSER_ITENS_ERC721"
        ) >= 0;
      assert.equal(isReverting, true, "Should be able to excute trade");
      return;
    }
    assert.fail("Expected throw not received");
  });

  it("Try to complete a trade which not belon to wallet", async () => {
    const tradeId = 1;
    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

    try {
      await BazaarEscrowInstance.executeTrade(tradeId, {
        from: WALLET_TWO,
      });
    } catch (error) {
      const isReverting =
        error.message.search(
          "WEB3BAZAR_ERROR: ERR_NOT_ALLOW_TO_TRANSER_ITENS_ERC721"
        ) >= 0;
      assert.equal(isReverting, true, "Should be able to excute trade");
      return;
    }
    assert.fail("Expected throw not received");
  });
});
