// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;
function c_0x5b911c7c(bytes32 c__0x5b911c7c) pure {}


import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract BazaarERC1155Collection is ERC1155 {
function c_0x97c62275(bytes32 c__0x97c62275) internal pure {}

    uint256 private _id = 1;
    string public name;
    string private _contractURI;

    constructor()
        public
        ERC1155("https://webazaar-meta-api.herokuapp.com/1155/detail/{id}")
    {c_0x97c62275(0xb9c161ea8bb8658ae827317ad8bdb3fd185639204cd22b82fb2b114e2317773d); /* function */ 

c_0x97c62275(0x9209ffc652c7de32b488bc8c490268cc413e3085eb971f43d0f1a88a556a3caa); /* line */ 
        c_0x97c62275(0x36e0d90e6223f30f71ec0b18fff49b7f0e932770e1ef2bd3fd2e771fdb19c682); /* statement */ 
_contractURI = "https://webazaar-meta-api.herokuapp.com/1155/detail/";
c_0x97c62275(0x06c81607280ceb5fc537046e40c41939d4a9291802a35e1aa1bb55cbb8cedafa); /* line */ 
        c_0x97c62275(0xb9c0204186b5e046c1477fbe8891493350cb3471a9005fa5c171f746d4b14661); /* statement */ 
name = "Bazaar ERC1155 v3";
c_0x97c62275(0x6b5f2311d87729ca126ba09d7bd3e66731c878d2f3bada36b1919bafdad9e285); /* line */ 
        c_0x97c62275(0xfd063b9c6d085b7796792c7ba10ad7da063ba7ec46b277d6011d94ec85d7e65d); /* statement */ 
mint(5);
c_0x97c62275(0xc5e6980289f00b82eccdf160dd91c2f04ded65440da138952f732dbba92affbe); /* line */ 
        c_0x97c62275(0xc121fde05508f198c10256890e2defe007d863d4ce0532a4158127e1efb9c35f); /* statement */ 
mint(10);
    }

    function mint(uint256 total) public returns (bool) {c_0x97c62275(0xe5a8e77d4a491074202e7e6ec6bde526b17cee2c1a97e96f15588a9171c1e87b); /* function */ 

c_0x97c62275(0xc8be2448eff1ef104e2b540ef1911007852d60c0a0eccc0c490b4c51bbc8d77f); /* line */ 
        c_0x97c62275(0xd8984957e24082a46c077316dd7c46cb8f3241ed8c7b8bec83e172c22e389707); /* requirePre */ 
c_0x97c62275(0x90221d97d493a2caab54370ca3d124f71db961389b7b48dbacd29ad9e22d541b); /* statement */ 
require(
            (total >= 1 && total <= 10),
            "NFT_MINT: GREATER THEN 1 LESS THEN 10"
        );c_0x97c62275(0x74b6674a36bbe398a20745f28002c318a52c8bdf600e367a05698bf552a27767); /* requirePost */ 

        // _mint(msg.sender, _id++, (total) * (1 ether), "");
c_0x97c62275(0xc422aeabdec36cf370ec8340ec29d08726dab3e652268338ddf17859578a80f2); /* line */ 
        c_0x97c62275(0xb06903434d85c51b1a6e2dd1ce95bff8234bfb0e972227e65b670eac7639d03b); /* statement */ 
_mint(msg.sender, _id++, (total), "");
c_0x97c62275(0xabd7972d267e51658136517d99653fd33746e881c7813114ae15d693927a7e87); /* line */ 
        c_0x97c62275(0x94f9d05ed2c236ad2fb7ba0d2bca2b361d7d6c5fb34236b2b8a966a7a0cc7c0d); /* statement */ 
return true;
    }

    // function setURI(string memory newuri) public isOwner returns (bool) {
    //     _setURI(newuri);
    //     return true;
    // }

    // function setContractURI(string memory newuri)
    //     public
    //     isOwner
    //     returns (bool)
    // {
    //     _contractURI = newuri;
    //     return true;
    // }

    // function setCollectionName(string memory _name)
    //     public
    //     isOwner
    //     returns (bool)
    // {
    //     name = _name;
    //     return true;
    // }

    // function contractURI() public view returns (string memory) {
    //     return _contractURI;
    // }
}
