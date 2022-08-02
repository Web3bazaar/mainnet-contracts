// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "./Web3BazaarEscrow.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract BazaarRaffleTicket is
    Context,
    ERC721,
    MultiAccessControl,
    ERC721Holder
{
    uint256 private id;
    // Base URI
    string private _baseURIextended;
    string private _contractURI;
    uint256 public constant MAX_SUPPLY;
    // address
    address public _projectTokenAddress;
    address public _bazaarContract;

    // raffles types
    uint8 private BRONZE = 1;
    uint8 private SILVER = 8;
    uint8 private GOLD = 20;

    // rafles prices
    uint256 public BRONZE_PRICE = 1500000000000000000;
    uint256 public SILVER_PRICE = 5000000000000000000;
    uint256 public GOLD_PRICE = 10000000000000000000;

    constructor()
        ERC721(
            "Web3Bazaar Raffle Ticket for Aavegotchi",
            "Web3Bazaar Raffle Ticket for Aavegotchi"
        )
    {
        id = 1;
        _contractURI = "https://raw.githubusercontent.com/Web3bazaar/giveways/main/projects/aavegotchi/contract";
        _baseURIextended = "https://raw.githubusercontent.com/Web3bazaar/giveways/main/projects/aavegotchi/data/";
        MAX_SUPPLY = 100000;

        //mumbai network
        _projectTokenAddress = 0x89A84dc58ABA7909818C471B2EbFBc94e6C96c41;
        _bazaarContract = 0x0A50B369f107aeF88E83B79F8E437EB623ac4a0a;

        //matic network
        //_projectTokenAddress = 0x385eeac5cb85a38a9a07a70c73e0a3271cfb54a7;
        // _bazaarContract = ;
    }

    /// Mint raffles ticket for callter based on type choosen and quantity specifiyed
    /// @param raffleType type of raffle ticket to mint
    /// @param quantity the amount of raffle ticket user want to mint
    /// @dev sets mmax amount of assets allowed per trade. Needs to be  <=1,000
    /// @return return tradeId created for this contract
    function mint(uint8 raffleType, uint8 quantity) external returns (uint256) {
        require(
            raffleType == BRONZE || raffleType == SILVER || raffleType == GOLD,
            "WEB3BAZAAR_RAFFLE_ERR: RAFFLE TYPE ISNT VALID"
        );
        require(
            quantity > 0 && quantity < 1000,
            "WEB3BAZAAR_RAFFLE_ERR: QUANTITY_RANGE_0_TO_1000"
        );

        uint256 unityPrice = 0;
        uint256 totalTickets = raffleType * quantity;

        if (raffleType == BRONZE) {
            unityPrice = BRONZE_PRICE;
        } else if (raffleType == SILVER) {
            unityPrice = SILVER_PRICE;
        } else if (raffleType == GOLD) {
            unityPrice = GOLD_PRICE;
        }
        require(
            unityPrice > 0,
            "WEB3BAZAAR_RAFFLE_ERR: UNITY_PRICE_ISNT_GREATER_THEN_ZERO"
        );

        uint256 totalAmount = unityPrice * quantity;

        address[] memory creatorTokenAddress = new address[](totalTickets);
        uint256[] memory creatorTokenId = new uint256[](totalTickets);
        uint256[] memory creatorTokenAmount = new uint256[](totalTickets);
        uint8[] memory creatorTokenType = new uint8[](totalTickets);

        //check the allownces for project token
        // require(totalAmount <= IERC20(_projectTokenAddress).allowance(msg.sender, address(this) ), 'WEB3BAZAAR_RAFLLES_ERR: ALLOWANCE_ISNT_ENOUGH');
        require(
            totalAmount <= IERC20(_projectTokenAddress).balanceOf(msg.sender),
            "WEB3BAZAAR_RAFFLE_ERR: ERR_NOT_ENOUGH_FUNDS_ERC20"
        );

        // mint ticket store on array to create trade after
        for (uint256 i = 0; i < totalTickets; i++) {
            id++;
            _mint(address(this), id);
            //fill array for trade
            creatorTokenAddress[i] = address(this);
            creatorTokenId[i] = id;
            creatorTokenAmount[i] = 1;
            creatorTokenType[i] = 3;
        }

        //  creator token addr
        address[] memory executerTokenAddress = new address[](1);
        executerTokenAddress[0] = _projectTokenAddress;
        // creatorTokenId
        uint256[] memory executerTokenId = new uint256[](1);
        executerTokenId[0] = 1;
        // creatorTokenAmount
        uint256[] memory executerTokenAmount = new uint256[](1);
        executerTokenAmount[0] = totalAmount;
        //creatorTokenType
        uint8[] memory executerTokenType = new uint8[](1);
        executerTokenType[0] = 1;

        uint256 tradeID = Web3BazaarEscrow(_bazaarContract).startTrade(
            creatorTokenAddress,
            creatorTokenId,
            creatorTokenAmount,
            creatorTokenType,
            msg.sender,
            executerTokenAddress,
            executerTokenId,
            executerTokenAmount,
            executerTokenType
        );

        return tradeID;
    }

    /// Approve ERC721 used to approve bazaar contract address
    /// @param erc721Address erc721 contract address
    /// @param to address to be approved
    /// @param approved flag to true/false to allow/disallow approvance
    /// @dev approve erc721 to spend tokens
    function approveERC721(
        address erc721Address,
        address to,
        bool approved
    ) external isOwner {
        ERC721(erc721Address).setApprovalForAll(to, approved);
    }

    /// Set prices for prices based on the type of ticket
    /// @param raffleType type of ticket
    /// @param newPrice new price for the ticket
    /// @dev set the type of tikcet with the new price
    /// @return bool if the new price was changed
    function setPriceByType(uint8 raffleType, uint256 newPrice)
        external
        isOwner
        returns (bool)
    {
        if (raffleType == BRONZE) {
            BRONZE_PRICE = newPrice;
        } else if (raffleType == SILVER) {
            SILVER_PRICE = newPrice;
        } else if (raffleType == GOLD) {
            GOLD_PRICE = newPrice;
        }
        return true;
    }

    //transfer nft tokens
    function transferERC721(
        address erc721Address,
        address from,
        address to,
        uint256 tokenId
    ) external isOwner {
        ERC721(erc721Address).safeTransferFrom(from, to, tokenId, "");
    }

    // set projectToken address
    function setTokenAddress(address projectToken) external isOwner {
        _projectTokenAddress = projectToken;
    }

    /// change the Web3Bazaar contract address
    /// @param newAddress new address for contract
    /// @dev set the type of tikcet with the new price
    function setWeb3BazaarContract(address newAddress) external isOwner {
        _bazaarContract = newAddress;
    }

    // set new base uri
    function setBaseURI(string memory baseURI_) external isOwner {
        _baseURIextended = baseURI_;
    }

    function setContractURI(string memory newuri)
        external
        isOwner
        returns (bool)
    {
        _contractURI = newuri;
        return true;
    }

    function baseURI() external view returns (string memory) {
        return _baseURIextended;
    }

    function contractURI() external view returns (string memory) {
        return _contractURI;
    }

    /// return the current id for the NFT
    /// @dev set the type of tikcet with the new price
    /// @return id current of for contract
    function getId() external view returns (uint256) {
        return id;
    }

    // approve erc20
    function approveERC20(
        address tokenAddress,
        address spender,
        uint256 amount
    ) public isOwner {
        IERC20(tokenAddress).approve(spender, amount);
    }

    // burn own tokens
    function burnOwn(uint256 tokenId) public isOwner {
        _burn(tokenId);
    }

    // transfer erc20
    function transferERC20(address tokenAddress, uint256 amount)
        public
        isOwner
    {
        SafeERC20.safeTransferFrom(
            IERC20(tokenAddress),
            address(this),
            msg.sender,
            amount
        );
    }

    // override original method
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }
}
