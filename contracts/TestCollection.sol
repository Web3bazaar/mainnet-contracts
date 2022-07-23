// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TestCollection is ERC721 {
    uint256 private _id;
    // Base URI
    string private _baseURIextended;
    string private _contractURI;

    constructor() ERC721("Test Collection", "Test Collection") {
        _id = 1;
        //_contractURI = "https://webazaar-meta-api.herokuapp.com/721/detail/";
        //_baseURIextended = "https://webazaar-meta-api.herokuapp.com/721/detail/{id}";
        _contractURI = "https://raw.githubusercontent.com/Web3bazaar/giveways/main/projects/sunflowersland/contract";
        _baseURIextended = "https://raw.githubusercontent.com/Web3bazaar/giveways/main/projects/sunflowersland/data/";
        //mint();
        //mint();
        //mint();
    }

    function mint() public returns (bool) {
        _mint(msg.sender, _id++);
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
