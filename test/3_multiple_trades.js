const Web3BazaarBatch = artifacts.require("Web3BazaarEscrow");
const Bazcoin = artifacts.require("Bazcoin");
const TestCollection = artifacts.require("TestCollection");
const BazaarERC1155Collection = artifacts.require("BazaarERC1155Collection");

const web3 = require("web3");

// contract(
//   "Web3BazaarEscrow Contract - Multiple trades open",
//   async (accounts) => {
//     const WALLET_ADMIN = accounts[0];
//     const WALLET_ONE = accounts[1];
//     const WALLET_TWO = accounts[2];
//     const WALLET_THREE = accounts[3];
//     const WALLET_FOUR = accounts[3];

//     it("Mints ERC20 tokens for Wallet One and three", async () => {
//       const BazcoinInstance = await Bazcoin.deployed();
//       // console.log('bazcoin conctract address: ', BazcoinInstance.address );
//       const assertBalance = 50e18;
//       await BazcoinInstance.mint({ from: WALLET_ONE });
//       await BazcoinInstance.mint({ from: WALLET_THREE });
//       let twoBalance = await BazcoinInstance.balanceOf(WALLET_ONE);
//       let toNumber = web3.utils.toBN(twoBalance);
//       // console.log('balance two: ', toNumber.toString())
//       assert.equal(
//         toNumber,
//         assertBalance,
//         "Balance should be " + assertBalance
//       );
//     });
//     it("Mints ERC721 Itens for Wallet Two", async () => {
//       const TestCollectionInstance = await TestCollection.deployed();
//       //console.log('bazcoin conctract address: ', TestCollectionInstance.address );

//       const MINT_IDS = [1, 2, 3, 4, 5];
//       for await (idx of MINT_IDS) {
//         await TestCollectionInstance.mint({ from: WALLET_TWO });
//       }

//       let nftsOwned = await TestCollectionInstance.balanceOf(WALLET_TWO);

//       let toNumber = web3.utils.toBN(nftsOwned);
//       //console.log('nft owned ', toNumber.toString() );
//       assert.equal(MINT_IDS.length, toNumber, "should own 5 nfts");
//     });

//     it("Mints ERC1155 Items for Wallet Four", async () => {
//       const BazaarERC1155CollectionInstance =
//         await BazaarERC1155Collection.deployed();
//       //console.log('bazcoin conctract address: ', TestCollectionInstance.address );

//       const MINT_IDS = [3, 4, 5, 6, 7];

//       for await (idx of MINT_IDS) {
//         await BazaarERC1155CollectionInstance.mint(10, { from: WALLET_FOU });
//       }

//       let nftsOwned = await BazaarERC1155CollectionInstance.balanceOf(
//         WALLET_TWO,
//         3
//       );
//       let toNumber = web3.utils.toBN(nftsOwned);
//       //console.log('nft owned ', toNumber.toString() );
//       assert.equal(10, toNumber, "Wallet Two MUST have 10 itens of id 3");
//     });
//   }
// );
