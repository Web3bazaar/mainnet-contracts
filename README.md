# Mainnet Contracts

## 👋 About this repo

This repo contains the solidity code used in the Bazaar smart contracts hosted on the compatible EVM testnets.

## 📝 About the Smart contract

The Web3 Bazaar dApp is supported by a non-custodial escrow contracts that enable peer-to-peer swaps of ERC-20, ERC-721 or ERC-1155 tokens. Contracts' only purpose is to switch asset ownership from one wallet address to another under the trades pre-established in it. 

### Bazaar smart contracts are:
- <b>fully permisionless</b>: every token from a supported standard can be traded by every wallet withouth censorship.
- <b>non-custodial</b>: Your assets never leave your wallet until the trade is complete.
- <b>free to use</b>: no fees are charged to access or swap assets within the Bazaar (apart from gas fees)
- <b>bundle transaction enabled</b>: asset owners can do 1:1 trades or mix assets in a bundle to trade for another set of assets owned by the counter-party.


### Networks available

| Network    | Contract address |
| ---          | ---        |
| Polygon | |

## 🔄 Smart contract state machine:

The contract handles a state machine within in order to determine and limit the parties interaction with it according to the actions already performed.

| State    | Description |
| ---          | ---        |
| Created | Terms are established in the Bazaar and ready to be executed by the counter-party. both parties can also change the status to "Cancelled"|
| Completed     | Counter-party executed the trade and assets swapped wallets. The trade is now in a status that can't be accessed or trigerred anymore |
| Cancelled      | One of both parties cancelled the trade and it can't be accessed or trigerred anymore |

### State flows

![this screenshot](/assets/trade_status.png)


## ✨ Smart contract Methods

### 1.Start trade

First, the trade must be submitted by the first counterpart (creator). Creator provides the trade terms and smart contract addresses of the assets both parties should commit to the trade. 
It proceeeds to  perform validations to confirm if all the parameters of the trade are valid. Contract checks if all the assets belong to the wallet addresses provided and if the creator gave the necessary permissions for the Bazaar smart contract to perform this asset exchange. The code detects if some issue occurs and throws an error code to the user as describbed in the ERROR LIST at the end of this Readme. 

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

### 2.Execute trade

When a trade is submitted and enters `created` status, the counter-party becomes able to execute it. It must have approved the Bazzar contract permissions to move its assets. 
A verification of the ownership of the assets provided in the trade terms is performed again before executing it.
Upon succesful verification the contract executes the swap and changes the status of the trade to `Completed`

![Fig.1](/assets/trade_flow.png)


#### Method Description

| Parameter     | Input |
| ---      | ---       |
| tradeId  | Input value returned by `startTrade` method|



### 3.getTrade

Get Trade methods gives information about the trade based on the `tradeId and user wallet it returns asset's stored for that trade.

| Paramater name | Description  |
| ---     |   ---        |
| tradeId        |   tradeId            |
| userWallet     |   user address       |


## 💀 Error List


| Code    | Description  |
| ---     |   ---        |
| CREATOR_PARMS_LEN_ERROR     |   Error sending parameters for creator        |
| EXECUTER_PARMS_LEN_ERROR    |   Error sending parameters for executer       |
| ERR_NOT_OWN_ID_ERC721       |   User isn't the other ERC721 ID asset        |
| ERR_NOT_ALLOW_TO_TRANSER_ITENS_ERC721     |  User did not give permission to spend ERC721 |
| ERR_NOT_ENOUGH_FUNDS_ERC20        |   The user has not have enough ERC20                           |
| ERR_NOT_ALLOW_SPEND_FUNDS         |   User did not give permission to spend ERC20         |
| ERR_NOT_ENOUGH_FUNDS_ERC1155      |   The user has not have enough asset on ERC1155                  |
| ERR_NOT_ALLOW_TO_TRANSER_ITENS_ERC1155     |   ser did not give permission to spend ERC1155        |
