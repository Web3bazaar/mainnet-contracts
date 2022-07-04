# Mainnet Contracts

## 👋 About this repo

This repo contains the solidity code used in the Bazaar smart contracts hosted on the compatible EVM mainnets.

## 📝 About the Smart contracts

The Web3 Bazaar dApp is supported by non-custodial escrow contracts that enable peer-to-peer swaps of ERC-20, ERC-721 or ERC-1155 tokens. Contracts' only purpose is to switch asset ownership from one wallet address to another under the trades pre-established in it. 

### Bazaar contracts are:
- <b>fully permisionless</b>: every token from a supported standard can be traded by every wallet withouth censorship.
- <b>non-custodial</b>: Your assets never leave your wallet until the trade is complete.
- <b>free to use</b>: no fees are charged to access or swap assets within the Bazaar (apart from gas fees)
- <b>bundle transaction enabled</b>: asset owners can do 1:1 trades or mix assets in a bundle to trade for another set of assets owned by the counter-party.


### Networks available

| Network    | Contract address |
| ---          | ---        |
| Polygon | [0x93cdc98317A07e83a9AA96F69AdA7Af4b37EBf44](https://polygonscan.com/address/0x93cdc98317A07e83a9AA96F69AdA7Af4b37EBf44) |

## 🔄 Contract state machine:

The contracts handle a state machine within in order to determine and limit the methods that are interactable according to the actions already performed by the parties.

| State    | Description |
| ---          | ---        |
| Created | Terms are established in the contract and counter-party can now execute the trade. Both parties can change the state to "Cancelled"|
| Completed     | Counter-party executed the trade and assets swapped wallets. The trade is now in a state can't be executed anymore |
| Cancelled      | One of both parties cancelled the trade and it can't be executed anymore |

### State flows

![this screenshot](/assets/trade_status.png)


## ✨ Contract Methods

### 1.startTrade

A trade is started by the Creator who provides the terms (assets' smart contract addresses and counter-party wallet address).
The smart contract procceeds with its validation an checks if all the assets belong to the wallet addresses provided and if the creator gave the necessary permissions for the smart contract to perform the swap. if an issue is detected the, the trade isn't submitted and the code returns an error as describbed in the ERROR LIST at the end of this Readme. 

#### Method Description

| Parameter    | Input  |
| ---          | ---        |
| creatorTokenAddress[]  | smart contract address of the asset you're going to deposit|
| creatorTokenId[]     | for ERC-721 and ERC-1155 assets only. Input the specific ID of the NFT you're depositing |
| creatorAmount[]      | amount of assets to deposit. Non-applicable to ERC-721 assets |
| creatorTokenType[]   | "1" for native token, "2" for ERC-20, "3" for ERC-721 or "4" for ERC-1155 |
| executerAddress      | wallet address of the trade counterparty|
| executorAssetContract    | smart contract address of the asset expected form counterparty|
| executorTokenAddress[]    | "1" for native token, "2" for ERC-20, "3" for ERC-721 or "4" for ERC-1155|
| executorTokenId[]    | for ERC-721 and ERC-1155 assets only. nNput the specific ID of the NFT you're expecting from the counterparty|
| executorAmount[]      | amount of assets to deposit. Non-applicable to ERC-721 assets|
| executorTokenType[]      | "1" for native token, "2" for ERC-20, "3" for ERC-721 or "4" for ERC-1155|

>Note: Once this method is called, the smart contract will return a unique `tradeId` value that will be used by the methods below in order to limit the operations to the designtaed parties and assets.

The contract then internally stores all the trade terms and assets' data depicted below:
![Fig.1](/assets/trades-image.png)

### 2.executeTrade

When a trade is submitted and enters `created` status and the counter-party becomes able to execute it. to do so, counter-party must first approve the contract methods to move its assets. 
A verification of the ownership of the assets provided in the trade terms is performed again before executing it.
Upon succesful verification the contract executes the swap and changes the status of the trade to `Completed`

![Fig.1](/assets/trade_flow.png)


#### Method Description

| Parameter     | Input |
| ---      | ---       |
| tradeId  | Input value returned by `startTrade` method|



### 3.getTrade

Get Trade methods gives information about the trade based on the `tradeId and user wallet. It returns asset's swapped in that trade.

| Paramater name | Description  |
| ---     |   ---        |
| tradeId        |   tradeId            |
| userWallet     |   user address       |


## 💀 Error List


| Code    | Description  |
| ---     |   ---        |
| CREATOR_PARMS_LEN_ERROR     |   Error sending parameters for creator        |
| EXECUTER_PARMS_LEN_ERROR    |   Error sending parameters for executer       |
| ERR_NOT_OWN_ID_ERC721       |   User doesn't own the other ERC721 ID asset        |
| ERR_NOT_ALLOWED_TO_TRANSER_ITEMS_ERC721     |  User did not give permission to spend ERC721 |
| ERR_NOT_ENOUGH_FUNDS_ERC20        |   The user does not have enough ERC20                           |
| ERR_NOT_ALLOWED_TO_SPEND_FUNDS         |   User did not give permission to spend ERC20         |
| ERR_NOT_ENOUGH_FUNDS_ERC1155      |   The user has not own the amount specified for ERC1155                  |
| ERR_NOT_ALLOWED_TO_TRANSER_ITEMS_ERC1155     |   user did not give permission to spend ERC1155        |
