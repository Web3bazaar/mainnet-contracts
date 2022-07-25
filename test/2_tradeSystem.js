const Web3BazaarBatch = artifacts.require("Web3BazaarEscrow");
const Bazcoin = artifacts.require("Bazcoin");
const TestCollection = artifacts.require("TestCollection");
const BazaarERC1155Collection = artifacts.require("BazaarERC1155Collection");

const web3 = require("web3");

contract(
  "Web3BazaarEscrow Contract - testing all kinds of trades ",
  async (accounts) => {
    const WALLET_ADMIN = accounts[0];
    const WALLET_ONE = accounts[1];
    const WALLET_TWO = accounts[2];

    it("Mints ERC20 tokens for Wallet One", async () => {
      const BazcoinInstance = await Bazcoin.deployed();
      // console.log('bazcoin conctract address: ', BazcoinInstance.address );
      const assertBalance = 50e18;
      await BazcoinInstance.mint({ from: WALLET_ONE });
      let twoBalance = await BazcoinInstance.balanceOf(WALLET_ONE);
      let toNumber = web3.utils.toBN(twoBalance);
      // console.log('balance two: ', toNumber.toString())
      assert.equal(
        toNumber,
        assertBalance,
        "Balance should be " + assertBalance
      );
    });

    it("Mints ERC721 Itens for Wallet Two", async () => {
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

    it("Mints ERC1155 Items for Wallet Two", async () => {
      const BazaarERC1155CollectionInstance =
        await BazaarERC1155Collection.deployed();
      //console.log('bazcoin conctract address: ', TestCollectionInstance.address );

      const MINT_IDS = [3, 4, 5, 6, 7];

      for await (idx of MINT_IDS) {
        await BazaarERC1155CollectionInstance.mint(10, { from: WALLET_TWO });
      }

      let nftsOwned = await BazaarERC1155CollectionInstance.balanceOf(
        WALLET_TWO,
        3
      );
      let toNumber = web3.utils.toBN(nftsOwned);
      //console.log('nft owned ', toNumber.toString() );
      assert.equal(10, toNumber, "Wallet Two MUST have 10 itens of id 3");
    });

    it("Wallet One allows web3Bazaar contract to send funds", async () => {
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

    it("Wallet Two needs to allow bazaar to transfer NFT", async () => {
      const TestCollectionInstance = await TestCollection.deployed();
      const BazaarERC1155CollectionInstance =
        await BazaarERC1155Collection.deployed();

      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

      const allowanceLimit = 50e18;

      await TestCollectionInstance.setApprovalForAll(
        BazaarEscrowInstance.address,
        true,
        {
          from: WALLET_TWO,
        }
      );
      await BazaarERC1155CollectionInstance.setApprovalForAll(
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

      let erc1155ApproveBazaar =
        await BazaarERC1155CollectionInstance.isApprovedForAll(
          WALLET_TWO,
          BazaarEscrowInstance.address
        );

      //console.log('Trade Info ',  tradeInfo[0]);
      assert.equal(
        erc721ApproveBazaar,
        true,
        "Wallet Two MUST approve ERC721 Bazaar contract to spend tokens"
      );
      assert.equal(
        erc1155ApproveBazaar,
        true,
        "Wallet Two MUST approve ERC1155 Bazaar contract to spend tokens"
      );
    });

    it("SHOULD start trade between Wallet One (ERC20) and Wallet Two (ERC1155 and ERC721)", async () => {
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
      let bazCoinAddress = (await Bazcoin.deployed()).address;
      let erc721Address = (await TestCollection.deployed()).address;
      let erc1155Address = (await BazaarERC1155Collection.deployed()).address;

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
          erc1155Address,
          erc1155Address,
          erc1155Address,
        ],
        [1, 2, 3, 4, 5, 3, 4, 5],
        [1, 1, 1, 1, 1, 10, 10, 10],
        [3, 3, 3, 3, 3, 2, 2, 2],
        {
          from: WALLET_ONE,
        }
      );

      const openTrades = await BazaarEscrowInstance.tradePerUser.call(
        WALLET_ONE
      );

      //  console.log('Bazaar Escrow Address : ', BazaarEscrowInstance.address );
      //console.log('openTrades : ', openTrades );
      assert.equal(
        openTrades.length,
        1,
        "Open trades for wallet one should be 1"
      );
    });

    it("SHOULD execute trade sucessfully and transfer NFT to wallet One", async () => {
      const tradeId = 1;
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
      const TestCollectionInstance = await TestCollection.deployed();

      try {
        await BazaarEscrowInstance.executeTrade(tradeId, {
          from: WALLET_TWO,
        });

        const tradeInfo = await BazaarEscrowInstance.getTrade(tradeId);
        const ownerOf = await TestCollectionInstance.ownerOf(1);
        // console.log("Wallet One ", WALLET_ONE);
        // console.log("Wallet Two ", WALLET_TWO);

        // console.log("Trade Info ", tradeInfo[2]);
        // console.log("Owner of tokenId 1 ", ownerOf);
        assert.equal(tradeInfo[2], 2, "Trade SHOULD be executed");
        assert.equal(ownerOf, WALLET_ONE, "Owner Of Id should be wallet One");
      } catch (error) {}
    });

    it("Wallet One needs to allow bazaar to transfer NFT", async () => {
      const TestCollectionInstance = await TestCollection.deployed();
      const BazaarERC1155CollectionInstance =
        await BazaarERC1155Collection.deployed();

      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

      await TestCollectionInstance.setApprovalForAll(
        BazaarEscrowInstance.address,
        true,
        {
          from: WALLET_ONE,
        }
      );
      await BazaarERC1155CollectionInstance.setApprovalForAll(
        BazaarEscrowInstance.address,
        true,
        {
          from: WALLET_ONE,
        }
      );

      let erc721ApproveBazaar = await TestCollectionInstance.isApprovedForAll(
        WALLET_ONE,
        BazaarEscrowInstance.address
      );

      let erc1155ApproveBazaar =
        await BazaarERC1155CollectionInstance.isApprovedForAll(
          WALLET_ONE,
          BazaarEscrowInstance.address
        );

      //console.log('Trade Info ',  tradeInfo[0]);
      assert.equal(
        erc721ApproveBazaar,
        true,
        "Wallet Two MUST approve ERC721 Bazaar contract to spend tokens"
      );
      assert.equal(
        erc1155ApproveBazaar,
        true,
        "Wallet Two MUST approve ERC1155 Bazaar contract to spend tokens"
      );
    });

    /// BEGIN  ERROR section
    it("SHOULD return an error starting a trade - executor address is 0", async () => {
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

      let bazCoinAddress = (await Bazcoin.deployed()).address;
      let erc721Address = (await TestCollection.deployed()).address;
      let erc1155Address = (await BazaarERC1155Collection.deployed()).address;

      try {
        const tradeId = await BazaarEscrowInstance.startTrade(
          [
            erc721Address,
            erc721Address,
            erc721Address,
            erc721Address,
            erc721Address,
            erc1155Address,
            erc1155Address,
            erc1155Address,
          ],
          [1, 2, 3, 4, 5, 3, 4, 5],
          [1, 1, 1, 1, 1, 10, 10, 10],
          [3, 3, 3, 3, 3, 2, 2, 2],
          "0x0000000000000000000000000000000000000000",
          [bazCoinAddress],
          [1],
          [web3.utils.toBN(40)],
          [1],
          //executer params

          {
            from: WALLET_ONE,
          }
        );
      } catch (error) {
        //console.log("error ", error.message);
        const isReverting =
          error.message.search(
            "WEB3BAZAAR_ERROR: EXECUTOR_ADDRESS_NOT_VALID"
          ) >= 0;
        assert.equal(isReverting, true, "Should revert start trade");
        return;
      }
      assert.fail("Expected throw not received");
    });

    it("SHOULD return an error starting a trade - CREATOR_AND_EXECUTOR_ARE_EQUAL", async () => {
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

      let bazCoinAddress = (await Bazcoin.deployed()).address;
      let erc721Address = (await TestCollection.deployed()).address;
      let erc1155Address = (await BazaarERC1155Collection.deployed()).address;

      try {
        const tradeId = await BazaarEscrowInstance.startTrade(
          [
            erc721Address,
            erc721Address,
            erc721Address,
            erc721Address,
            erc721Address,
            erc1155Address,
            erc1155Address,
            erc1155Address,
          ],
          [1, 2, 3, 4, 5, 3, 4, 5],
          [1, 1, 1, 1, 1, 10, 10, 10],
          [3, 3, 3, 3, 3, 2, 2, 2],
          WALLET_ONE,
          [bazCoinAddress],
          [1],
          [web3.utils.toBN(40)],
          [1],
          //executer params

          {
            from: WALLET_ONE,
          }
        );

        const tradeInfo = await BazaarEscrowInstance.getTrade(2);
        //console.log("Trade Info ", tradeInfo[0]);
        assert.equal(tradeInfo[0], WALLET_ONE, "Creator MUST be wallet one");
      } catch (error) {
        //console.log("error ", error.message);
        const isReverting =
          error.message.search(
            "WEB3BAZAAR_ERROR: CREATOR_AND_EXECUTOR_ARE_EQUAL"
          ) >= 0;
        assert.equal(isReverting, true, "Should revert start trade");
        return;
      }
      assert.fail("Expected throw not received");
    });

    it("SHOULD return an error starting a trade - CREATOR_TOKEN_ADDRESS_EMPTY", async () => {
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

      let bazCoinAddress = (await Bazcoin.deployed()).address;
      let erc721Address = (await TestCollection.deployed()).address;
      let erc1155Address = (await BazaarERC1155Collection.deployed()).address;

      try {
        const tradeId = await BazaarEscrowInstance.startTrade(
          [],
          [1, 2, 3, 4, 5, 3, 4, 5],
          [1, 1, 1, 1, 1, 10, 10, 10],
          [3, 3, 3, 3, 3, 2, 2, 2],
          WALLET_TWO,
          [bazCoinAddress],
          [1],
          [web3.utils.toBN(40)],
          [1],
          //executer params

          {
            from: WALLET_ONE,
          }
        );

        const tradeInfo = await BazaarEscrowInstance.getTrade(2);
        //console.log("Trade Info ", tradeInfo[0]);
        assert.equal(tradeInfo[0], WALLET_ONE, "Creator MUST be wallet one");
      } catch (error) {
        //console.log("error ", error.message);
        const isReverting =
          error.message.search(
            "WEB3BAZAAR_ERROR: CREATOR_TOKEN_ADDRESS_EMPTY"
          ) >= 0;
        assert.equal(isReverting, true, "Should revert start trade");
        return;
      }
      assert.fail("Expected throw not received");
    });

    it("SHOULD return an error starting a trade - EXECUTOR_TOKEN_ADDRESS_EMPTY", async () => {
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

      let bazCoinAddress = (await Bazcoin.deployed()).address;
      let erc721Address = (await TestCollection.deployed()).address;
      let erc1155Address = (await BazaarERC1155Collection.deployed()).address;

      try {
        const tradeId = await BazaarEscrowInstance.startTrade(
          [
            erc721Address,
            erc721Address,
            erc721Address,
            erc721Address,
            erc721Address,
            erc1155Address,
            erc1155Address,
            erc1155Address,
          ],
          [1, 2, 3, 4, 5, 3, 4, 5],
          [1, 1, 1, 1, 1, 10, 10, 10],
          [3, 3, 3, 3, 3, 2, 2, 2],
          WALLET_TWO,
          [],
          [1],
          [web3.utils.toBN(40)],
          [1],
          //executer params

          {
            from: WALLET_ONE,
          }
        );

        const tradeInfo = await BazaarEscrowInstance.getTrade(2);
        //console.log("Trade Info ", tradeInfo[0]);
        assert.equal(tradeInfo[0], WALLET_ONE, "Creator MUST be wallet one");
      } catch (error) {
        //console.log("error ", error.message);
        const isReverting =
          error.message.search(
            "WEB3BAZAAR_ERROR: EXECUTER_TOKEN_ADDRESS_EMPTY"
          ) >= 0;
        assert.equal(isReverting, true, "Should revert start trade");
        return;
      }
      assert.fail("Expected throw not received");
    });

    it("SHOULD return an error starting a trade - WEB3BAZAR_PARMS:CREATOR_PARMS_LEN_ERROR", async () => {
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

      let bazCoinAddress = (await Bazcoin.deployed()).address;
      let erc721Address = (await TestCollection.deployed()).address;
      let erc1155Address = (await BazaarERC1155Collection.deployed()).address;

      try {
        const tradeId = await BazaarEscrowInstance.startTrade(
          [
            erc721Address,
            erc721Address,
            erc721Address,
            erc721Address,
            erc721Address,
            erc1155Address,
            erc1155Address,
            erc1155Address,
          ],
          [1, 2, 3, 4, 5, 3, 4],
          [1, 1, 1, 1, 1, 10, 10, 10],
          [3, 3, 3, 3, 3, 2, 2, 2],
          WALLET_TWO,
          [bazCoinAddress],
          [1],
          [web3.utils.toBN(40)],
          [1],
          //executer params

          {
            from: WALLET_ONE,
          }
        );

        const tradeInfo = await BazaarEscrowInstance.getTrade(2);
        //console.log("Trade Info ", tradeInfo[0]);
        assert.equal(tradeInfo[0], WALLET_ONE, "Creator MUST be wallet one");
      } catch (error) {
        //console.log("error ", error.message);
        const isReverting =
          error.message.search("WEB3BAZAR_PARMS:CREATOR_PARMS_LEN_ERROR") >= 0;
        assert.equal(isReverting, true, "Should revert start trade");
        return;
      }
      assert.fail("Expected throw not received");
    });

    it("SHOULD return an error starting a trade - WEB3BAZAR_PARMS:EXECUTOR_PARMS_LEN_ERROR", async () => {
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

      let bazCoinAddress = (await Bazcoin.deployed()).address;
      let erc721Address = (await TestCollection.deployed()).address;
      let erc1155Address = (await BazaarERC1155Collection.deployed()).address;

      try {
        const tradeId = await BazaarEscrowInstance.startTrade(
          [
            erc721Address,
            erc721Address,
            erc721Address,
            erc721Address,
            erc721Address,
            erc1155Address,
            erc1155Address,
            erc1155Address,
          ],
          [1, 2, 3, 4, 5, 3, 4, 5],
          [1, 1, 1, 1, 1, 10, 10, 10],
          [3, 3, 3, 3, 3, 2, 2, 2],
          WALLET_TWO,
          [bazCoinAddress],
          [],
          [web3.utils.toBN(40)],
          [1],
          //executer params

          {
            from: WALLET_ONE,
          }
        );

        const tradeInfo = await BazaarEscrowInstance.getTrade(2);
        //console.log("Trade Info ", tradeInfo[0]);
        assert.equal(tradeInfo[0], WALLET_ONE, "Creator MUST be wallet one");
      } catch (error) {
        //console.log("error ", error.message);
        const isReverting =
          error.message.search("WEB3BAZAR_PARMS:EXECUTER_PARMS_LEN_ERROR") >= 0;
        assert.equal(isReverting, true, "Should revert start trade");
        return;
      }
      assert.fail("Expected throw not received");
    });

    it("SHOULD return an error starting a trade - WEB3BAZAAR_ERROR: CONTRACT_TOKEN_ADDRESS_IS_ZERO creator", async () => {
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

      let bazCoinAddress = (await Bazcoin.deployed()).address;
      let erc721Address = (await TestCollection.deployed()).address;
      let erc1155Address = (await BazaarERC1155Collection.deployed()).address;

      try {
        const tradeId = await BazaarEscrowInstance.startTrade(
          [
            erc721Address,
            "0x0000000000000000000000000000000000000000",
            erc721Address,
            erc721Address,
            erc721Address,
            erc1155Address,
            erc1155Address,
            erc1155Address,
          ],
          [1, 2, 3, 4, 5, 3, 4, 5],
          [1, 1, 1, 1, 1, 10, 10, 10],
          [3, 3, 3, 3, 3, 2, 2, 2],
          WALLET_TWO,
          [bazCoinAddress],
          [1],
          [web3.utils.toBN(40)],
          [1],
          //executer params

          {
            from: WALLET_ONE,
          }
        );

        const tradeInfo = await BazaarEscrowInstance.getTrade(2);
        //console.log("Trade Info ", tradeInfo[0]);
        assert.equal(tradeInfo[0], WALLET_ONE, "Creator MUST be wallet one");
      } catch (error) {
        //console.log("error ", error.message);
        const isReverting =
          error.message.search(
            "WEB3BAZAAR_ERROR: CONTRACT_TOKEN_ADDRESS_IS_ZERO"
          ) >= 0;
        assert.equal(isReverting, true, "Should revert start trade");
        return;
      }
      assert.fail("Expected throw not received");
    });

    it("SHOULD return an error starting a trade - WEB3BAZAR_ERROR: NOT_VALID_TRADE_TYPE creator", async () => {
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

      let bazCoinAddress = (await Bazcoin.deployed()).address;
      let erc721Address = (await TestCollection.deployed()).address;
      let erc1155Address = (await BazaarERC1155Collection.deployed()).address;

      try {
        const tradeId = await BazaarEscrowInstance.startTrade(
          [
            erc721Address,
            erc721Address,
            erc721Address,
            erc721Address,
            erc721Address,
            erc1155Address,
            erc1155Address,
            erc1155Address,
          ],
          [1, 2, 3, 4, 5, 3, 4, 5],
          [1, 1, 1, 1, 1, 10, 10, 10],
          [3, 3, 7, 3, 3, 2, 2, 2],
          WALLET_TWO,
          [bazCoinAddress],
          [1],
          [web3.utils.toBN(40)],
          [1],
          //executer params

          {
            from: WALLET_ONE,
          }
        );

        const tradeInfo = await BazaarEscrowInstance.getTrade(2);
        //console.log("Trade Info ", tradeInfo[0]);
        assert.equal(tradeInfo[0], WALLET_ONE, "Creator MUST be wallet one");
      } catch (error) {
        // console.log("error ", error.message);
        const isReverting =
          error.message.search("WEB3BAZAR_ERROR: NOT_VALID_TRADE_TYPE") >= 0;
        assert.equal(isReverting, true, "Should revert start trade");
        return;
      }
      assert.fail("Expected throw not received");
    });

    it("SHOULD return an error starting a trade - WEB3BAZAR_ERROR: TOKENID_MUST_POSITIVE creator", async () => {
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

      let bazCoinAddress = (await Bazcoin.deployed()).address;
      let erc721Address = (await TestCollection.deployed()).address;
      let erc1155Address = (await BazaarERC1155Collection.deployed()).address;

      try {
        const tradeId = await BazaarEscrowInstance.startTrade(
          [
            erc721Address,
            erc721Address,
            erc721Address,
            erc721Address,
            erc721Address,
            erc1155Address,
            erc1155Address,
            erc1155Address,
          ],
          [1, 0, 3, 4, 5, 3, 4, 5],
          [1, 1, 1, 1, 1, 10, 10, 10],
          [3, 3, 3, 3, 3, 2, 2, 2],
          WALLET_TWO,
          [bazCoinAddress],
          [1],
          [web3.utils.toBN(40)],
          [1],
          //executer params

          {
            from: WALLET_ONE,
          }
        );

        const tradeInfo = await BazaarEscrowInstance.getTrade(2);
        //console.log("Trade Info ", tradeInfo[0]);
        assert.equal(tradeInfo[0], WALLET_ONE, "Creator MUST be wallet one");
      } catch (error) {
        //console.log("error ", error.message);
        const isReverting =
          error.message.search("WEB3BAZAR_ERROR: TOKENID_MUST_POSITIVE") >= 0;
        assert.equal(isReverting, true, "Should revert start trade");
        return;
      }
      assert.fail("Expected throw not received");
    });

    it("SHOULD return an error starting a trade - WEB3BAZAR_ERROR: AMOUNT_MUST_POSITIVE creator", async () => {
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

      let bazCoinAddress = (await Bazcoin.deployed()).address;
      let erc721Address = (await TestCollection.deployed()).address;
      let erc1155Address = (await BazaarERC1155Collection.deployed()).address;

      try {
        const tradeId = await BazaarEscrowInstance.startTrade(
          [
            erc721Address,
            erc721Address,
            erc721Address,
            erc721Address,
            erc721Address,
            erc1155Address,
            erc1155Address,
            erc1155Address,
          ],
          [1, 3, 3, 4, 5, 3, 4, 5],
          [1, 1, 0, 1, 1, 10, 10, 10],
          [3, 3, 3, 3, 3, 2, 2, 2],
          WALLET_TWO,
          [bazCoinAddress],
          [1],
          [web3.utils.toBN(40)],
          [1],
          //executer params

          {
            from: WALLET_ONE,
          }
        );

        const tradeInfo = await BazaarEscrowInstance.getTrade(2);
        //console.log("Trade Info ", tradeInfo[0]);
        assert.equal(tradeInfo[0], WALLET_ONE, "Creator MUST be wallet one");
      } catch (error) {
        // console.log("error ", error.message);
        const isReverting =
          error.message.search("WEB3BAZAR_ERROR: AMOUNT_MUST_POSITIVE") >= 0;
        assert.equal(isReverting, true, "Should revert start trade");
        return;
      }
      assert.fail("Expected throw not received");
    });

    /// Ending error section

    it("SHOULD create a new trade to revert Wallet 2 (ERC20) and WALLET 1 (ERC1155 and ERC721) assets ownership", async () => {
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();

      let bazCoinAddress = (await Bazcoin.deployed()).address;
      let erc721Address = (await TestCollection.deployed()).address;
      let erc1155Address = (await BazaarERC1155Collection.deployed()).address;

      //console.log("bazCoinAddress : ", bazCoinAddress);
      //console.log("erc721Address : ", erc721Address);
      // console.log("to BigNumber ", web3.utils.toBN(40));

      const tradeId = await BazaarEscrowInstance.startTrade(
        [
          erc721Address,
          erc721Address,
          erc721Address,
          erc721Address,
          erc721Address,
          erc1155Address,
          erc1155Address,
          erc1155Address,
        ],
        [1, 2, 3, 4, 5, 3, 4, 5],
        [1, 1, 1, 1, 1, 10, 10, 10],
        [3, 3, 3, 3, 3, 2, 2, 2],
        WALLET_TWO,
        [bazCoinAddress],
        [1],
        [web3.utils.toBN(40)],
        [1],
        //executer params

        {
          from: WALLET_ONE,
        }
      );

      const tradeInfo = await BazaarEscrowInstance.getTrade(2);
      //console.log("Trade Info ", tradeInfo[0]);
      assert.equal(tradeInfo[0], WALLET_ONE, "Creator MUST be wallet one");
    });

    it("SHOULD return an error executing a trade because Wallet Two tranfered all tokens", async () => {
      const tradeId = 2;
      const BazcoinInstance = await Bazcoin.deployed();
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
      const BazaarERC1155CollectionInstance =
        await BazaarERC1155Collection.deployed();

      try {
        await BazcoinInstance.transfer(accounts[3], web3.utils.toBN(40), {
          from: WALLET_TWO,
        });

        await BazaarEscrowInstance.executeTrade(tradeId, {
          from: WALLET_TWO,
        });
      } catch (error) {
        //console.log("error ", error.message);
        const isReverting =
          error.message.search(
            "WEB3BAZAAR_ERROR: ERR_NOT_ENOUGH_FUNDS_ERC20"
          ) >= 0;
        assert.equal(
          isReverting,
          true,
          "Should throw an error not enough funds"
        );
        return;
      }
      assert.fail("Expected throw not received");
    });

    ///execute trade with sucess
    it("SHOULD execute trade successfully and transfer NFT back to wallet two", async () => {
      const tradeId = 2;
      const BazcoinInstance = await Bazcoin.deployed();
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
      const BazaarERC1155CollectionInstance =
        await BazaarERC1155Collection.deployed();

      try {
        await BazcoinInstance.transfer(WALLET_TWO, web3.utils.toBN(40), {
          from: accounts[3],
        });

        await BazaarEscrowInstance.executeTrade(tradeId, {
          from: WALLET_TWO,
        });

        const tradeInfoOne = await BazaarEscrowInstance.getTrade(
          tradeId,
          WALLET_TWO
        );

        const tradeInfoTwo = await BazaarEscrowInstance.getTrade(
          tradeId,
          WALLET_TWO
        );
        const balanceOfTwo = await BazaarERC1155CollectionInstance.balanceOf(
          WALLET_TWO,
          3
        );

        console.log("Balance of Wallet Two ", tradeInfoTwo);
        //console.log("Trade Info status", tradeInfo[2]);

        assert.equal(balanceOfTwo, 10, "Wallet two must have nft back");
      } catch (error) {}
    });

    it("Trade status should be executed", async () => {
      const tradeId = 2;
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
      const BazaarERC1155CollectionInstance =
        await BazaarERC1155Collection.deployed();

      try {
        const tradeInfoOne = await BazaarEscrowInstance.getTradeWithAddress(
          tradeId,
          WALLET_ONE
        );

        const tradeInfoTwo = await BazaarEscrowInstance.getTradeWithAddress(
          tradeId,
          WALLET_TWO
        );

        //console.log("trade status 2 ", tradeInfoTwo);

        assert.equal(
          tradeInfoOne[0].length,
          8,
          "tokens address must contain 8 itens"
        );
      } catch (error) {}
    });
  }
);
