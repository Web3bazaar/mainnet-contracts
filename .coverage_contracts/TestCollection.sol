// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
function c_0x4a062964(bytes32 c__0x4a062964) pure {}


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TestCollection is ERC721 {
function c_0x6e8fb491(bytes32 c__0x6e8fb491) internal pure {}

    uint256 private _id;
    // Base URI
    string private _baseURIextended;
    string private _contractURI;

    constructor() ERC721("Test Collection", "Test Collection") {c_0x6e8fb491(0x764ae32630e6297e547b0b62a912c7ef3f6811cfe10cba4af148936ff90e9171); /* function */ 

c_0x6e8fb491(0x7d99aeaa2c69d1ae74eb090f7dc48a65b3edef06392848622feacaf9564e23e0); /* line */ 
        c_0x6e8fb491(0xd6ef1711a0497284d6609e1c13a4c2195c5030b749736010b0d088f55658cbf8); /* statement */ 
_id = 1;
        //_contractURI = "https://webazaar-meta-api.herokuapp.com/721/detail/";
        //_baseURIextended = "https://webazaar-meta-api.herokuapp.com/721/detail/{id}";
c_0x6e8fb491(0x583351934bd3068857e64423cba29d2a846fe5fc4ac32d3af6f220755f431286); /* line */ 
        c_0x6e8fb491(0x9ecfcf2db50223b542ef9bc2dc769a50a516bfae543f74132d3dd6dc4bdd2284); /* statement */ 
_contractURI = "https://raw.githubusercontent.com/Web3bazaar/giveways/main/projects/sunflowersland/contract";
c_0x6e8fb491(0x49c80138413c2de896c257dbd0aa0681afb2e25a1093ee281888d32fcf5c9e7d); /* line */ 
        c_0x6e8fb491(0xb604236483ece2048c0adedc51dc87e182522c24c1cd451ea081514b6ff723c9); /* statement */ 
_baseURIextended = "https://raw.githubusercontent.com/Web3bazaar/giveways/main/projects/sunflowersland/data/";
        //mint();
        //mint();
        //mint();
    }

    function mint() public returns (bool) {c_0x6e8fb491(0x9fe4e190402c0ef59bb1b8901678f832c25a03b3dd0034333da8da8db29684c8); /* function */ 

c_0x6e8fb491(0x6b362598f0150ced128f99da0ee6efa8f1b25932a93ad3df60460c3586dadbb2); /* line */ 
        c_0x6e8fb491(0xa41e220c82c3334daa0f9c29190b42078f036f40bd6a79369f86d5cf873daa88); /* statement */ 
_mint(msg.sender, _id++);
c_0x6e8fb491(0xa1831ce7014bb92effa7b2f6ec3ac316d0cfb7fea98d2a7e491ef8219e9e390e); /* line */ 
        c_0x6e8fb491(0xb23973c921e200af41be53e168b9707c6cdcb86a9d2ba8b249c20b9df651431c); /* statement */ 
return true;
    }

    // set new base uri
    // function setBaseURI(string memory baseURI_) external isOwner() {
    //     _baseURIextended = baseURI_;
    // }

    // // override original method
    // function _baseURI() internal view virtual override returns (string memory) {
    //     return _baseURIextended;
    // }

    // function setContractURI(string memory newuri)  public  isOwner() returns (bool)
    // {
    //     _contractURI = newuri;
    //     return true;
    // }

    // function contractURI() public view returns (string memory) {
    //     return _contractURI;
    // }
}
