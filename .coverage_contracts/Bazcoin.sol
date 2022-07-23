// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
function c_0xaef97207(bytes32 c__0xaef97207) pure {}


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract ERC20Capped is ERC20 {
function c_0x6261ff29(bytes32 c__0x6261ff29) internal pure {}


    // define 21 milions as mark cap 
    uint256 public maxSupply = 21000000 * 10**decimals();
    

    constructor(string memory _name, 
                string memory _symbol) ERC20(_name, _symbol) 
    {c_0x6261ff29(0xf4c5a05cfe0582ddf3e37c4a418e737266ec8be9ec807384c9e8ec8cb134d5c1); /* function */ 
}
   

    function _mintCapped(address _account, uint256 _value) internal {c_0x6261ff29(0xa67d4ec0fbedadd6835845883bfa68979223ce1784dc97de4b89bb782e8ab30d); /* function */ 

c_0x6261ff29(0x481e7bdcff11e63a88c5eef521498ffb81e9df7e0979170524b50f8cd026fded); /* line */ 
        c_0x6261ff29(0xf9d65272256b9a71fd8f1218eb9e217ddcfaee96cae72c23f5f96642b554713d); /* requirePre */ 
c_0x6261ff29(0xa4afa343719be54ce24f46e2447cdea665be4e4a80439941e0ff5536f71ec858); /* statement */ 
require(totalSupply() + _value <= maxSupply, 'ERR_EXCEEDED_MAX_SUPPLY');c_0x6261ff29(0x16ee8579cf5b88a4eede2202f89c4e13f5252ab05ddc0b7a3eed82ab1dd3fc4f); /* requirePost */ 

c_0x6261ff29(0x1bb393853af2d7ef22a4066d547a61b9518281d3537933d7714a2a2477c34bdd); /* line */ 
        c_0x6261ff29(0x5abbf0f7ebec56e421a1f2171a0de44e8ffc7a3434c369bdb6fb64374fbdf565); /* statement */ 
_mint(_account, _value);
    }    
}

contract Bazcoin is ERC20Capped {
function c_0xc1774ad6(bytes32 c__0xc1774ad6) internal pure {}

    
    uint256 private _mintAmount = 50 *  10**decimals();

    constructor() 
        ERC20Capped("Bazcoin", "Bazcoin") 
    {c_0xc1774ad6(0x0ca1027e5f56fa15f046fc71e5ad4544fc3a1a04e1b344290cbeceb7d657219f); /* function */ 

c_0xc1774ad6(0xecac6030fd81fc58fa38f31e36a9bffc9a9a48c1f4c508f4b36ba815db826d67); /* line */ 
        c_0xc1774ad6(0xd25f3a4f06a2c587080dd07725d2474ba52ae7ff5d16a8b272e8e124dc90832a); /* statement */ 
_mintCapped( msg.sender , 5000 * 10**decimals() ); 
    }

    function mint() public payable returns(uint256)
    {c_0xc1774ad6(0xb2958f24952bf6234457b92ba3b6bc57e557ed2cdbbbcfd472b978761dc50f3a); /* function */ 

c_0xc1774ad6(0x13a9d034842d6fbf095f3201044b9543f282acf850276f2c810be43cf6ba8198); /* line */ 
        c_0xc1774ad6(0x0651e5b37309e74c8f73a0aa2db75d414319e34e2159af85fa8583e1c0388f27); /* statement */ 
_mintCapped(msg.sender,  _mintAmount);
c_0xc1774ad6(0xd3f827f92caea9216ac2601be135868a6a758ddef8a06e4148e79e798e280f48); /* line */ 
        c_0xc1774ad6(0xc52e010d826fc3e8204117425d263d003794003bc5b0cef028fb0058cf0c3b44); /* statement */ 
return _mintAmount;
    }

}