// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/// @author drBrown
/// @title MultiAccessControl contract
contract MultiAccessControl {
    mapping(address => bool) internal _owners;

    modifier isOwner() {
        require(_owners[msg.sender] == true, "ERR_NOT_OWNER");
        _;
    }

    constructor() {
        _owners[msg.sender] = true;
    }

    function addOwnership(address payable newOwner) external isOwner {
        require(newOwner != address(0), "ERR_ZERO_ADDR");
        _owners[newOwner] = true;
    }

    function removeOwnership(address payable existingOwner) external isOwner {
        require(_owners[existingOwner] == true, "ERR_ADDR_NOT_OWNER");
        _owners[existingOwner] = false;
    }
}

/// @author drBrown
/// @title Web3BazaarEscrow contract
contract Web3BazaarEscrow is
    Context,
    ERC1155Holder,
    ERC721Holder,
    MultiAccessControl
{
    event NewTrade(
        address indexed creator,
        address indexed executor,
        uint256 tradeId
    );
    event FinishTrade(address indexed executor, uint256 tradeId);

    uint256 private _tradeId;
    mapping(uint256 => Trade) internal _transactions;
    mapping(address => uint256[]) internal _openTrades;

    uint256 public openTradeCount;
    uint256 public totalCompletedTrade;

    enum TradeStatus {
        NON,
        TRADE_CREATED,
        TRADE_COMPLETED,
        TRADE_CANCELLED
    }
    enum UserStatus {
        NON,
        OPEN,
        DEPOSIT,
        CLAIM
    }
    enum TradeType {
        NON,
        ERC20,
        ERC1155,
        ERC721
    }

    struct TradeCounterpart {
        address contractAddr;
        uint256 idAsset;
        uint256 amount;
        TradeType traderType;
        UserStatus traderStatus;
    }
    struct Trade {
        address creator;
        address executor;
        uint256 id;
        mapping(address => TradeUser) _traders;
        TradeStatus tradeStatus;
    }
    struct TradeUser {
        uint256[] tokenAddressIdx;
        mapping(uint256 => TradeCounterpart) _counterpart;
    }

    constructor() MultiAccessControl() {
        openTradeCount = 0;
        totalCompletedTrade = 0;
    }

    // External functions

    /// cancelTrade -  To invalidate an already created trade. Can be called by both the trade creator or executor
    /// @param tradeId to cancel
    /// @dev changes the status of the trade to cancelled
    /// @return all true  if trade was cancelled
    function cancelTrade(uint256 tradeId) external returns (bool) {
        Trade storage store = _transactions[tradeId];
        require(
            store.tradeStatus == TradeStatus.TRADE_CREATED,
            "WEB3BAZAAR_ERROR: TRADE_STATUS ISNT CREATED"
        );
        require(
            store.executor == msg.sender || store.creator == msg.sender,
            "WEB3BAZAAR_ERROR: EXECUTER ISNT CREATOR OR EXECUTER"
        );
        _transactions[tradeId].tradeStatus = TradeStatus.TRADE_CANCELLED;
        openTradeCount = openTradeCount - 1;
        return true;
    }

    /// executeTrade - to confirm a swap proposed by a creator counter-party. executor calls it to initiate the trade
    /// @param tradeId to execute trade
    /// @dev verifies assets ownership from both parties before swapping them.
    /// @return id of the trade
    function executeTrade(uint256 tradeId) external returns (uint256) {
        Trade storage store = _transactions[tradeId];
        require(
            store.tradeStatus == TradeStatus.TRADE_CREATED,
            "WEB3BAZAAR_ERROR: TRADE_STATUS ISNT CREATED"
        );

        address executer = store.executor;
        address creator = store.creator;
        require(
            executer == msg.sender,
            "WEB3BAZAAR_ERROR: CALLER INST THE EXECUTER"
        );
        TradeCounterpart storage tempSwap;
        for (
            uint256 i = 0;
            i < store._traders[creator].tokenAddressIdx.length;
            i++
        ) {
            uint256 tokenAddressIdx = store._traders[creator].tokenAddressIdx[
                i
            ];
            tempSwap = store._traders[creator]._counterpart[tokenAddressIdx];
            if (tempSwap.traderType == TradeType.ERC20) {
                swapERC20(
                    creator,
                    executer,
                    tempSwap.contractAddr,
                    tempSwap.amount
                );
            } else if (tempSwap.traderType == TradeType.ERC721) {
                swapERC721(
                    creator,
                    executer,
                    tempSwap.contractAddr,
                    tempSwap.idAsset
                );
            } else if (tempSwap.traderType == TradeType.ERC1155) {
                swapERC1155(
                    creator,
                    executer,
                    tempSwap.contractAddr,
                    tempSwap.idAsset,
                    tempSwap.amount
                );
            }
        }
        for (
            uint256 i = 0;
            i < store._traders[executer].tokenAddressIdx.length;
            i++
        ) {
            uint256 tokenAddressIdx = store._traders[executer].tokenAddressIdx[
                i
            ];
            tempSwap = store._traders[executer]._counterpart[tokenAddressIdx];
            if (tempSwap.traderType == TradeType.ERC20) {
                swapERC20(
                    executer,
                    creator,
                    tempSwap.contractAddr,
                    tempSwap.amount
                );
            } else if (tempSwap.traderType == TradeType.ERC721) {
                swapERC721(
                    executer,
                    creator,
                    tempSwap.contractAddr,
                    tempSwap.idAsset
                );
            } else if (tempSwap.traderType == TradeType.ERC1155) {
                swapERC1155(
                    executer,
                    creator,
                    tempSwap.contractAddr,
                    tempSwap.idAsset,
                    tempSwap.amount
                );
            }
        }
        _transactions[_tradeId].tradeStatus = TradeStatus.TRADE_COMPLETED;
        removeTradeForUser(msg.sender, tradeId);
        removeTradeForUser(_transactions[tradeId].creator, tradeId);
        totalCompletedTrade = totalCompletedTrade + 1;
        openTradeCount = openTradeCount - 1;
        emit FinishTrade(msg.sender, tradeId);
        return tradeId;
    }

    /// starttrade - to verify creator and executor assets ownership and start the trade

    /// @param creatorTokenAddress array containing the address of the contract of each asset to be swapped by the creator
    /// @param creatorTokenId array containing tokenId of each asset (only applicable for erc721 and erc1155) to be swapped by the creator
    /// @param creatorAmount array containing the amount of each token (only applicable for erc1155 and erc20) to be swapped by the creator
    /// @param creatorTokenType array containing the token standard of each asset (erc20, erc721 and erc1155) to be swapped by the creator
    /// @param executerAddress wallet address of counterparty
    /// @param executorTokenAddress array containing the address of the contract of each asset to be swapped by the executor
    /// @param executorTokenId array containing tokenId of each asset (only applicable for erc721 and erc1155) to be swapped by the executor
    /// @param executorAmount array containing the amount of each token (only applicable for erc1155 and erc20) to be swapped by the executor
    /// @param executorTokenType array containing the token standard of each asset (erc20, erc721 and erc1155) to be swapped by the executor
    /// @dev checks if both users own all assets requested by the trade creator and initiates the trade if verification returns true
    /// @return all trades created by a user
    function startTrade(
        address[] memory creatorTokenAddress,
        uint256[] memory creatorTokenId,
        uint256[] memory creatorAmount,
        uint8[] memory creatorTokenType,
        address executerAddress,
        address[] memory executorTokenAddress,
        uint256[] memory executorTokenId,
        uint256[] memory executorAmount,
        uint8[] memory executorTokenType
    ) external returns (uint256) {
        address creatorAddress = msg.sender;
        require(
            executerAddress != address(0),
            "WEB3BAZAAR_ERROR: EXECUTER_ADDRESS_NOT_VALID"
        );
        require(
            creatorAddress != address(0),
            "WEB3BAZAAR_ERROR: CREATOR_ADDRESS_NOT_VALID"
        );
        require(
            executerAddress != creatorAddress,
            "WEB3BAZAAR_ERROR: CREATOR_AND_EXECUTER_ARE_EQUAL"
        );
        require(
            creatorTokenAddress.length > 0,
            "WEB3BAZAAR_ERROR: CREATOR_TOKEN_ADDRESS_EMPTY"
        );
        require(
            executorTokenAddress.length > 0,
            "WEB3BAZAAR_ERROR: EXECUTER_TOKEN_ADDRESS_EMPTY"
        );

        require(
            creatorTokenAddress.length == creatorTokenId.length &&
                creatorTokenAddress.length == creatorAmount.length &&
                creatorTokenAddress.length == creatorTokenType.length,
            "WEB3BAZAR_PARMS:CREATOR_PARMS_LEN_ERROR"
        );
        require(
            executorTokenAddress.length == executorTokenId.length &&
                executorTokenAddress.length == executorAmount.length &&
                executorTokenAddress.length == executorTokenType.length,
            "WEB3BAZAR_PARMS:EXECUTER_PARMS_LEN_ERROR"
        );

        _tradeId++;
        _transactions[_tradeId].id = _tradeId;
        _transactions[_tradeId].creator = creatorAddress;
        _transactions[_tradeId].executor = executerAddress;
        for (uint256 i = 0; i < creatorTokenAddress.length; i++) {
            require(
                creatorTokenAddress[i] != address(0),
                "WEB3BAZAAR_ERROR: CREATOR_TOKEN_ADDRESS_IS_ZERO"
            );
            verifyTradeIntegrity(
                creatorTokenAddress[i],
                creatorTokenId[i],
                creatorAmount[i],
                creatorTokenType[i]
            );
            if (TradeType(creatorTokenType[i]) == TradeType.ERC20) {
                verifyERC20(
                    creatorAddress,
                    creatorTokenAddress[i],
                    creatorAmount[i],
                    true
                );
            } else if (TradeType(creatorTokenType[i]) == TradeType.ERC721) {
                verifyERC721(
                    creatorAddress,
                    creatorTokenAddress[i],
                    creatorTokenId[i],
                    true
                );
            } else if (TradeType(creatorTokenType[i]) == TradeType.ERC1155) {
                verifyERC1155(
                    creatorAddress,
                    creatorTokenAddress[i],
                    creatorAmount[i],
                    creatorTokenId[i],
                    true
                );
            }
            _transactions[_tradeId]
                ._traders[creatorAddress]
                .tokenAddressIdx
                .push(i + 1);
            _transactions[_tradeId]
                ._traders[creatorAddress]
                ._counterpart[i + 1]
                .contractAddr = creatorTokenAddress[i];
            _transactions[_tradeId]
                ._traders[creatorAddress]
                ._counterpart[i + 1]
                .idAsset = creatorTokenId[i];
            _transactions[_tradeId]
                ._traders[creatorAddress]
                ._counterpart[i + 1]
                .amount = creatorAmount[i];
            _transactions[_tradeId]
                ._traders[creatorAddress]
                ._counterpart[i + 1]
                .traderType = TradeType(creatorTokenType[i]);
            _transactions[_tradeId]
                ._traders[creatorAddress]
                ._counterpart[i + 1]
                .traderStatus = UserStatus.OPEN;
        }
        for (uint256 i = 0; i < executorTokenAddress.length; i++) {
            require(
                executorTokenAddress[i] != address(0),
                "WEB3BAZAAR_ERROR: EXECUTER_TOKEN_ADDRESS_IS_ZERO"
            );
            verifyTradeIntegrity(
                executorTokenAddress[i],
                executorTokenId[i],
                executorAmount[i],
                executorTokenType[i]
            );
            if (TradeType(executorTokenType[i]) == TradeType.ERC20) {
                verifyERC20(
                    executerAddress,
                    executorTokenAddress[i],
                    executorAmount[i],
                    false
                );
            } else if (TradeType(executorTokenType[i]) == TradeType.ERC721) {
                verifyERC721(
                    executerAddress,
                    executorTokenAddress[i],
                    executorTokenId[i],
                    false
                );
            } else if (TradeType(executorTokenType[i]) == TradeType.ERC1155) {
                verifyERC1155(
                    executerAddress,
                    executorTokenAddress[i],
                    executorAmount[i],
                    executorTokenId[i],
                    false
                );
            }
            _transactions[_tradeId]
                ._traders[executerAddress]
                .tokenAddressIdx
                .push(i + 1);
            _transactions[_tradeId]
                ._traders[executerAddress]
                ._counterpart[i + 1]
                .contractAddr = executorTokenAddress[i];
            _transactions[_tradeId]
                ._traders[executerAddress]
                ._counterpart[i + 1]
                .idAsset = executorTokenId[i];
            _transactions[_tradeId]
                ._traders[executerAddress]
                ._counterpart[i + 1]
                .amount = executorAmount[i];
            _transactions[_tradeId]
                ._traders[executerAddress]
                ._counterpart[i + 1]
                .traderType = TradeType(executorTokenType[i]);
            _transactions[_tradeId]
                ._traders[executerAddress]
                ._counterpart[i + 1]
                .traderStatus = UserStatus.OPEN;
        }
        _transactions[_tradeId].tradeStatus = TradeStatus.TRADE_CREATED;
        _openTrades[creatorAddress].push(_tradeId);
        _openTrades[executerAddress].push(_tradeId);
        emit NewTrade(creatorAddress, executerAddress, _tradeId);
        openTradeCount = openTradeCount + 1;
        return _tradeId;
    }

    // External visible functions

    /// getTrade - this method returns data about the trade based on tradeId
    /// @param tradeId to obtain information
    /// @dev indexes and returns information about the trade
    /// @return creator address, executor address and trade status
    function getTrade(uint256 tradeId)
        external
        view
        returns (
            address,
            address,
            uint8
        )
    {
        Trade storage store = _transactions[tradeId];
        return (store.creator, store.executor, uint8(store.tradeStatus));
    }

    /// getTrade - this method returns data about the trade based on tradeId and user wallet
    /// @param tradeId to obtain information
    /// @param userWallet to check trades for that wallet address
    /// @dev indexes internal sctructure and information based on tradeId and wallet address
    /// @return arrays of tokenAddress, tokenIds, tokenAmount, tokenType
    function getTrade(uint256 tradeId, address userWallet)
        external
        view
        returns (
            address[] memory,
            uint256[] memory,
            uint256[] memory,
            uint8[] memory
        )
    {
        Trade storage store = _transactions[tradeId];
        uint256[] memory tokenAddressIdx = store
            ._traders[userWallet]
            .tokenAddressIdx;

        address[] memory _tradeTokenAddress = new address[](
            tokenAddressIdx.length
        );
        uint256[] memory _tradeTokenIds = new uint256[](tokenAddressIdx.length);
        uint256[] memory _tradeTokenAmount = new uint256[](
            tokenAddressIdx.length
        );
        uint8[] memory _tradeType = new uint8[](tokenAddressIdx.length);

        for (uint256 y = 0; y < tokenAddressIdx.length; y++) {
            TradeCounterpart memory tInfo = store
                ._traders[userWallet]
                ._counterpart[tokenAddressIdx[y]];
            _tradeTokenAddress[y] = tInfo.contractAddr;
            _tradeTokenIds[y] = tInfo.idAsset;
            _tradeTokenAmount[y] = tInfo.amount;
            _tradeType[y] = uint8(tInfo.traderType);
        }
        return (
            _tradeTokenAddress,
            _tradeTokenIds,
            _tradeTokenAmount,
            _tradeType
        );
    }

    /// tradePerUser - Returns all open trades for a given wallet address
    /// @param u to check open trades based on wallet address
    /// @dev returns all trades open for an address stored in the _openTrades index
    /// @return all trades open for a user
    function tradePerUser(address u) external view returns (uint256[] memory) {
        return (_openTrades[u]);
    }

    // External functions that are pure
    // ...

    /// public function
    /// ...

    /// internal function

    /// verifyERC721 - verifies ERC721 token ownership from wallet address
    /// @param from for wallet address
    /// @param tokenAddress address of the ERC721 contract
    /// @param tokenAddress tokenId of that token
    /// @param verifyAproval to verify Bazaar smart contract's approval to move this token
    /// @dev verifyERC721 to check the ownership of ERC721 tokens specified in a trade created for that wallet address
    /// @return true if verification is sucessful
    function verifyERC721(
        address from,
        address tokenAddress,
        uint256 tokenId,
        bool verifyAproval
    ) internal view returns (bool) {
        require(
            from == ERC721(tokenAddress).ownerOf(tokenId),
            "WEB3BAZAAR_ERROR: ERR_NOT_OWN_ID_ERC721"
        );
        if (verifyAproval) {
            require(
                ERC721(tokenAddress).isApprovedForAll(from, address(this)),
                "WEB3BAZAR_ERROR: ERR_NOT_ALLOW_TO_TRANSER_ITENS_ERC721"
            );
        }
        return true;
    }

    /// verifyERC20 - verifies ERC20 token ownership and amount available from wallet address
    /// @param from for wallet address
    /// @param tokenAddress address of the ERC20 contract
    /// @param amount of that token
    /// @param verifyAproval to verify Bazaar smart contract's approval to move this token
    /// @dev verifyERC20 to check the ownership of ERC20 tokens and amounts specified in a trade created for that wallet address
    /// @return true if the amount owned by the user is equal or superior to the value specified in the trade
    function verifyERC20(
        address from,
        address tokenAddress,
        uint256 amount,
        bool verifyAproval
    ) internal view returns (bool) {
        require(
            amount <= IERC20(tokenAddress).balanceOf(from),
            "WEB3BAZAAR_ERROR: ERR_NOT_ENOUGH_FUNDS_ERC20"
        );
        if (verifyAproval) {
            require(
                amount <= IERC20(tokenAddress).allowance(from, address(this)),
                "WEB3BAZAR_ERROR: ERR_NOT_ALLOW_SPEND_FUNDS"
            );
        }
        return true;
    }

    /// VerifyERC1155 - Verifies ERC1155 token ownership and amount available from wallet address
    /// @param from for wallet address
    /// @param tokenAddress address of the ERC1155 contract
    /// @param amount of that token
    /// @param tokenId of that token
    /// @param verifyAproval to check the ownership of ERC1155 tokens and amounts specified in a trade created for that wallet address
    /// @return true if the amount owned by the user is equal or superior to the value specified in the trade
    function verifyERC1155(
        address from,
        address tokenAddress,
        uint256 amount,
        uint256 tokenId,
        bool verifyAproval
    ) internal view returns (bool) {
        require(
            tokenId > 0,
            "WEB3BAZAAR_ERROR: STAKE_ERC1155_ID_SHOULD_GREATER_THEN_0"
        );
        require(
            amount > 0 &&
                amount <= ERC1155(tokenAddress).balanceOf(from, tokenId),
            "WEB3BAZAAR_ERROR: ERR_NOT_ENOUGH_FUNDS_ERC1155"
        );
        if (verifyAproval) {
            require(
                ERC1155(tokenAddress).isApprovedForAll(from, address(this)),
                "WEB3BAZAR_ERROR: ERR_NOT_ALLOW_TO_TRANSER_ITENS_ERC1155"
            );
        }
        return true;
    }

    /// SwapERC721-  moves token ERC721 from one address to another
    /// @param from owner address
    /// @param to destination address
    /// @param tokenAddress of the ERC20 contract
    /// @param tokenId of that token
    /// @dev Swaps token ERC721 from one address to another. First calls method verifyERC721 to check token ownership then swaps it from the owner to the destination address
    /// @return true if swap is successful
    function swapERC721(
        address from,
        address to,
        address tokenAddress,
        uint256 tokenId
    ) internal returns (bool) {
        verifyERC721(from, tokenAddress, tokenId, true);
        ERC721(tokenAddress).safeTransferFrom(from, to, tokenId, "");
        return true;
    }

    /// SwapERC1155 - moves tokens ERC1155 from one address to another
    /// @param from owner address
    /// @param to for destination address
    /// @param tokenAddress of the ERC1155 contract
    /// @param tokenId of that token
    /// @param amount of that token
    /// @dev Swaps token(s) ERC721 from one address to another. First calls method verifyERC1155 to check token ownership and amount held then swaps them from the owner to the destination address
    /// @return true if swap is successful
    function swapERC1155(
        address from,
        address to,
        address tokenAddress,
        uint256 tokenId,
        uint256 amount
    ) internal returns (bool) {
        verifyERC1155(from, tokenAddress, amount, tokenId, true);
        ERC1155(tokenAddress).safeTransferFrom(
            from,
            to,
            tokenId,
            amount,
            "0x01"
        );
        return true;
    }

    /// Swap ERC20 - moves tokens ERC20 from one address to another
    /// @param from owner ess
    /// @param to for destination address
    /// @param tokenAddress address of the ERC20 contract
    /// @param amount of that token
    /// @dev Swaps token(s) ERC20 from one address to another. First calls method verifyERC20 to check token ownership and amount held then swaps them from the owner to the destination address
    /// @return true if swap is successful
    function swapERC20(
        address from,
        address to,
        address tokenAddress,
        uint256 amount
    ) internal returns (bool) {
        verifyERC20(from, tokenAddress, amount, true);
        SafeERC20.safeTransferFrom(IERC20(tokenAddress), from, to, amount);
        return true;
    }

    /// private functions

    /// removeTradeForUser - remove an open trade from _openTrades array
    /// @param u user address to check open trades
    /// @param tradeId  from the trade you want to remove
    /// @dev retrieves the value of the state of the variable `storedData`
    /// @return all trades open for a user
    function removeTradeForUser(address u, uint256 tradeId)
        private
        returns (bool)
    {
        uint256[] memory userTrades = _openTrades[u];

        if (_openTrades[u].length == 1) {
            _openTrades[u][0] = 0;
            return true;
        }
        for (uint256 i = 0; i < userTrades.length - 1; i++) {
            if (userTrades[i] == tradeId) {
                _openTrades[u][i] = _openTrades[u][userTrades.length - 1];
                _openTrades[u].pop();
                return true;
            }
        }
        return false;
    }

    /// vverifyTradeIntegrity- verifies integrety of data from tokens be swapped
    /// @param tokenAddress  to check open trades for wallet address
    /// @param tokenId from the trade you want to remove
    /// @param amount tradeId from the trade you want to remove
    /// @param tokenType tradeId from the trade you want to remove
    /// @dev retrieves the value of the state variable `storedData`
    /// @return all trades open for a user
    function verifyTradeIntegrity(
        address tokenAddress,
        uint256 tokenId,
        uint256 amount,
        uint8 tokenType
    ) private pure returns (bool) {
        require(
            tokenAddress != address(0),
            "WEB3BAZAAR_ERROR: CREATOR_CONTRACT_NOT_VALID"
        );
        require(
            tokenType > uint8(TradeType.NON) &&
                tokenType <= uint8(TradeType.ERC721),
            "WEB3BAZAR_ERROR: NOT_VALID_TRADE_TYPE"
        );
        require(tokenId > 0, "WEB3BAZAR_ERROR: TOKENID_MUST_POSITIVE");
        require(amount > 0, "WEB3BAZAR_ERROR: AMOUNT_MUST_POSITIVE");
        return true;
    }
}
