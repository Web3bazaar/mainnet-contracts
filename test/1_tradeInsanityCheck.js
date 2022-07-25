const Web3BazaarBatch = artifacts.require("Web3BazaarEscrow");
const Bazcoin = artifacts.require("Bazcoin");
const TestCollection = artifacts.require("TestCollection");
const web3 = require("web3");

// https://www.youtube.com/watch?v=PeiTfWN7Ik0

contract("Web3BazaarBatch Contract - Check requirements ", async (accounts) => {
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

    const MINT_IDS = [1, 2, 3, 4, 5, 6, 7];
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

  it("Should set new max asset per trade", async () => {
    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
    let newMaxAssetPerTrade = 25;
    await BazaarEscrowInstance.setAssetPerTrade(newMaxAssetPerTrade);
    const numMaxPerTrades = await BazaarEscrowInstance.numAssetsPerTrade.call();
    //console.log("Max Per trades : ", numMaxPerTrades.toNumber());

    //  console.log('Bazaar Escrow Address : ', BazaarEscrowInstance.address );
    //console.log('openTrades : ', openTrades );
    assert.equal(newMaxAssetPerTrade, numMaxPerTrades);
  });
  it("Should throw error setting new max assets per trades", async () => {
    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
    let newMaxAssetPerTrade = 1001;

    try {
      await BazaarEscrowInstance.setAssetPerTrade(newMaxAssetPerTrade);
    } catch (error) {
      const isReverting =
        error.message.search(
          "WEB3BAZAAR_ERROR: assetPerTrade should be greater then 1 and less then 1000"
        ) >= 0;
      assert.equal(
        isReverting,
        true,
        "Should not be able to set new max number per trade"
      );
      return;
    }
    assert.fail("Expected throw not received");
  });
  // ###
  it("Should throw error starting trade with more itens that what allowed", async () => {
    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
    let bazCoinAddress = (await Bazcoin.deployed()).address;
    let erc721Address = (await TestCollection.deployed()).address;
    const numMaxPerTrades = await BazaarEscrowInstance.numAssetsPerTrade.call();
    console.log("Max Per trades : ", numMaxPerTrades.toNumber());

    const maxItensForTest = 400;
    let executerAddressArray = [],
      executerIds = [],
      executerAmounts = [],
      executerTypes = [];
    for (let i = 1; i <= maxItensForTest; i++) {
      executerAddressArray.push(erc721Address);
      executerIds.push(i);
      executerAmounts.push(1);
      executerTypes.push(3);
    }
    console.log("Executer Address length: ", executerAddressArray.length);
    try {
      const tradeId = await BazaarEscrowInstance.startTrade(
        [bazCoinAddress],
        [1],
        [web3.utils.toBN(40)],
        [1],
        //executer params
        WALLET_TWO,
        executerAddressArray,
        executerIds,
        executerAmounts,
        executerTypes,
        {
          from: WALLET_ONE,
        }
      );
    } catch (error) {
      //console.log("error : ", error);
      const isReverting =
        error.message.search(
          "WEB3BAZAAR_ERROR: EXECUTER_TOKENS_EXCEED_MAX_ASSET_PER_TRADE"
        ) >= 0;
      assert.equal(isReverting, true, "Should not be able start trade");
      return;
    }
    assert.fail("Expected throw not received");
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

  it("Initializate second trade between Wallet 1 and Wallet 2 with sucess", async () => {
    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
    let bazCoinAddress = (await Bazcoin.deployed()).address;
    let erc721Address = (await TestCollection.deployed()).address;

    //console.log("bazCoinAddress : ", bazCoinAddress);
    //console.log("erc721Address : ", erc721Address);
    // console.log("to BigNumber ", web3.utils.toBN(40));

    const tradeId = await BazaarEscrowInstance.startTrade(
      [bazCoinAddress],
      [1],
      [web3.utils.toBN(5)],
      [1],
      //executer params
      WALLET_TWO,
      [erc721Address],
      [6],
      [1],
      [3],
      {
        from: WALLET_ONE,
      }
    );

    const openTrades = await BazaarEscrowInstance.tradePerUser.call(WALLET_ONE);

    //  console.log('Bazaar Escrow Address : ', BazaarEscrowInstance.address );
    //console.log('openTrades : ', openTrades );
    assert.equal(
      openTrades.length,
      2,
      "Open trades for wallet one should be 1"
    );
  });
  it("Initializate third trade between Wallet 1 and Wallet 2 with sucess", async () => {
    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
    let bazCoinAddress = (await Bazcoin.deployed()).address;
    let erc721Address = (await TestCollection.deployed()).address;

    //console.log("bazCoinAddress : ", bazCoinAddress);
    //console.log("erc721Address : ", erc721Address);
    // console.log("to BigNumber ", web3.utils.toBN(40));

    const tradeId = await BazaarEscrowInstance.startTrade(
      [bazCoinAddress],
      [1],
      [web3.utils.toBN(5)],
      [1],
      //executer params
      WALLET_TWO,
      [erc721Address],
      [7],
      [1],
      [3],
      {
        from: WALLET_ONE,
      }
    );

    const openTrades = await BazaarEscrowInstance.tradePerUser(WALLET_TWO);

    //  console.log('Bazaar Escrow Address : ', BazaarEscrowInstance.address );
    //console.log('openTrades : ', openTrades );
    assert.equal(
      openTrades.length,
      3,
      "Open trades for wallet one should be 3"
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

  it("Try to complete a trade which not belong to wallet", async () => {
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

  it("Should be error to cancel trade cause its not creator or executer", async () => {
    const tradeId = 1;
    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

    try {
      await BazaarEscrowInstance.cancelTrade(tradeId, {
        from: accounts[3],
      });
    } catch (error) {
      const isReverting =
        error.message.search(
          "WEB3BAZAAR_ERROR: EXECUTER ISNT CREATOR OR EXECUTER"
        ) >= 0;
      assert.equal(isReverting, true, "Should be able to excute trade");
      return;
    }
    assert.fail("Expected throw not received");
  });

  it("Allow BazaarContract to spend NFT", async () => {
    const TestCollectionInstance = await TestCollection.deployed();

    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

    await TestCollectionInstance.setApprovalForAll(
      BazaarEscrowInstance.address,
      true,
      {
        from: WALLET_TWO,
      }
    );

    let erc721ApproveBazaar = await TestCollectionInstance.isApprovedForAll(
      WALLET_TWO,
      BazaarEscrowInstance.address
    );

    //console.log('Trade Info ',  tradeInfo[0]);
    assert.equal(
      erc721ApproveBazaar,
      true,
      "Wallet Two MUST approve ERC721 Bazaar contract to spend tokens"
    );
  });

  it("Should execute second trade with success", async () => {
    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

    try {
      let trades = await BazaarEscrowInstance.tradePerUser(WALLET_TWO);
      for (var i in trades) {
        //console.log("before - trade id ", trades[i].toNumber());
      }

      await BazaarEscrowInstance.executeTrade(2, {
        from: WALLET_TWO,
      });
      let trades2 = await BazaarEscrowInstance.tradePerUser(WALLET_TWO);
      for (var i in trades2) {
        //console.log("after - trade id ", trades2[i].toNumber());
      }

      //  console.log('Bazaar Escrow Address : ', BazaarEscrowInstance.address );
      //console.log("openTrades after second execution: ", openTrades);
      assert.equal(trades2.length, 2, "Open trades for wallet one should be 2");
    } catch (ex) {
      console.log("error executing second trade ", ex);
    }
  });

  // it("Should execute third trade with success", async () => {
  //   let tradeId = 3;
  //   const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

  //   try {
  //     let tradeActors = await BazaarEscrowInstance.getTrade(3);
  //     let creatoraddress = tradeActors[0];
  //     let executerAddress = tradeActors[1];
  //     let trade1 = await BazaarEscrowInstance.getTrade(1);
  //     let trade2 = await BazaarEscrowInstance.getTrade(2);
  //     let trade3 = await BazaarEscrowInstance.getTrade(3);

  //     console.log("trade 1 status ", trade1[2].toNumber());
  //     console.log("trade 2 status ", trade2[2].toNumber());
  //     console.log("trade 3 status ", trade3[2].toNumber());
  //     let trades = await BazaarEscrowInstance.tradePerUser(WALLET_TWO);
  //     for (var i in trades) {
  //       console.log("trade id ", trades[i].toNumber());
  //     }

  //     // for await (idx of tradesTwo) {
  //     //   console.log("open for user ", tradesTwo[idx].toNumber());
  //     // }

  //     assert.equal(
  //       WALLET_TWO,
  //       executerAddress,
  //       "Wallet two should be the executer"
  //     );

  //     await BazaarEscrowInstance.executeTrade(3, {
  //       from: WALLET_TWO,
  //     });

  //     const openTrades = await BazaarEscrowInstance.tradePerUser(WALLET_TWO);
  //     //console.log("openTrades after third execute : ", openTrades);
  //     assert.equal(
  //       openTrades.length,
  //       1,
  //       "Open trades for wallet one should be 1"
  //     );
  //   } catch (error) {
  //     console.log("Error third ", error);
  //   }
  // });

  it("Should getted all info about trade", async () => {
    const tradeId = 1;
    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
    let bazCoinAddress = (await Bazcoin.deployed()).address;
    let erc721Address = (await TestCollection.deployed()).address;

    try {
      let tradeActors = await BazaarEscrowInstance.getTrade(tradeId);
      let creatoraddress = tradeActors[0];
      let executerAddress = tradeActors[1];
      //console.log("creatoraddress: ", creatoraddress);
      //console.log("executerAddress: ", executerAddress);

      assert.equal(creatoraddress, WALLET_ONE, "Should be wallet of creator");
      assert.equal(
        executerAddress,
        WALLET_TWO,
        "Should be able wallet of executer"
      );

      let tradeCreatorInfo = await BazaarEscrowInstance.getTradeWithAddress(
        tradeId,
        creatoraddress
      );
      let creatorTokenAddress = tradeCreatorInfo[0];
      //console.log("Creator token address : ", creatorTokenAddress);

      assert.equal(
        bazCoinAddress,
        creatorTokenAddress,
        "creatorTokenAddress should the bazcoin contract address"
      );

      let tradeExecuterInfo = await BazaarEscrowInstance.getTradeWithAddress(
        tradeId,
        executerAddress
      );
      let executerTokenAddress = tradeExecuterInfo[0];
      //console.log("executerTokenAddress : ", executerTokenAddress);

      assert.equal(
        erc721Address,
        executerTokenAddress,
        "executerTokenAddress should the ERC721 collection contract address"
      );
    } catch (error) {
      return;
    }
  });

  it("Should cancel the trade", async () => {
    const tradeId = 1;
    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

    try {
      await BazaarEscrowInstance.cancelTrade(tradeId, {
        from: WALLET_TWO,
      });

      const creatorOpenTrade = await BazaarEscrowInstance.tradePerUser.call(
        WALLET_ONE
      );
      const executerOpenTrade = await BazaarEscrowInstance.tradePerUser.call(
        WALLET_TWO
      );

      assert.equal(
        creatorOpenTrade.length,
        executerOpenTrade.length,
        "Creator and Executer opentrades should be the same"
      );

      assert.equal(
        creatorOpenTrade.length,
        0,
        "Creator open trade MUST be zero"
      );
    } catch (error) {}
  });
  it("Trade status SHOULD be cancelled", async () => {
    const tradeId = 1;
    const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
    const tradeInfo = await BazaarEscrowInstance.getTrade(1);
    //console.log("Trade Info ", tradeInfo);
    //console.log("Trade Info 2:  ", tradeInfo[2].toNumber());

    assert.equal(tradeInfo[2].toNumber(), 3, "Status SHOULD be cancelled");
  });
});
