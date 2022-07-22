const Web3BazaarBatch = artifacts.require("Web3BazaarEscrow");
const Bazcoin = artifacts.require("Bazcoin");
const TestCollection = artifacts.require("TestCollection");
const BazaarERC1155Collection = artifacts.require("BazaarERC1155Collection");

const web3 = require("web3");

contract(
  "Web3BazaarBatch Contract - testing all kinds of trades ",
  async (accounts) => {
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
      assert.equal(
        toNumber,
        assertBalance,
        "Balance should be " + assertBalance
      );
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

    it("Mint ERC1155 Itens for Wallet Two", async () => {
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

    it("Wallet Two needs to allow bazaar to tranfer NFT", async () => {
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

    it("SHOULD initializate trade between Wallet 1 (ERC20) and Wallet 2 (ERC1155 and ERC721)", async () => {
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

    it("SHOULD execute trade with sucess and tranfer nft to wallet ONE", async () => {
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
        assert.equal(ownerOf, WALLET_ONE, "Owner Of Id should be wallet one");
      } catch (error) {}
    });

    it("Wallet One needs to allow bazaar to tranfer NFT", async () => {
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

    it("SHOULD initializate trade on reverse way Wallet 2 (ERC20) and WALLET 1 (ERC1155 and ERC721)", async () => {
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

      const openTrades = await BazaarEscrowInstance.tradePerUser.call(
        WALLET_TWO
      );

      //  console.log('Bazaar Escrow Address : ', BazaarEscrowInstance.address );
      console.log("openTrades : ", openTrades);
      assert.equal(openTrades.length, 0, "Trade ID open should be 2");
    });

    it("SHOULD execute trade with sucess and tranfer nft to wallet ONE", async () => {
      const tradeId = 2;
      const BazaarEscrowInstance = await Web3BazaarBatch.deployed();
      const TestCollectionInstance = await TestCollection.deployed();

      try {
        await BazaarEscrowInstance.executeTrade(tradeId, {
          from: WALLET_TWO,
        });

        const tradeInfo = await BazaarEscrowInstance.getTrade(tradeId);
        const ownerOf = await TestCollectionInstance.ownerOf(1);
        console.log("Wallet One ", WALLET_ONE);
        console.log("Wallet Two ", WALLET_TWO);

        console.log("Trade Info ", tradeInfo[2]);
        console.log("Owner of tokenId 1 ", ownerOf);
        assert.equal(tradeInfo[2], 2, "Trade SHOULD be executed");
        assert.equal(WALLET_TWO, ownerOf, "Trade SHOULD be executed");
      } catch (error) {}
    });
  }
);
