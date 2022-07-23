// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
function c_0x7f183659(bytes32 c__0x7f183659) pure {}


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
function c_0x0b167a52(bytes32 c__0x0b167a52) internal pure {}

    mapping(address => bool) internal _owners;

    modifier isOwner() {c_0x0b167a52(0x4e01c8990009f5565b8cca8058068ee7bb901534518e641abdd3a1ce22430f46); /* function */ 

c_0x0b167a52(0x95879a5412f0389920f95eda8329b4debe4cd5124c35735111acbea6540510b2); /* line */ 
        c_0x0b167a52(0xb50ff9557577824f9225b0225089d5e46704879296347b6c4c2cc4647b2036e3); /* requirePre */ 
c_0x0b167a52(0x4e0a8863079af0373e0c5c925db1f018430f2db64d314cc9279e40cd72a4cf0a); /* statement */ 
require(_owners[msg.sender] == true, "ERR_NOT_OWNER");c_0x0b167a52(0xbe69170a29816e561f47cd676339a8396d06e803a8fc0d6d93d1cd174a7a1492); /* requirePost */ 

c_0x0b167a52(0xd7403a287d749f17e4ae2050e7b8b996eee106ff5b6510888d07e893d1774f79); /* line */ 
        _;
    }

    constructor() {c_0x0b167a52(0x8a4d28d3016c7420790906de72dd384c4de505dc5cc6a363acec50ed37e7336e); /* function */ 

c_0x0b167a52(0xeecc2ff2126c3f056972c2145427c4a62dabd7e3b65cd0b1114fc5d2d4f04f64); /* line */ 
        c_0x0b167a52(0xaff8edf95aa3f557276bd89f9b56139ba8f54d960573577ca8e08614b373614d); /* statement */ 
_owners[msg.sender] = true;
    }

    function addOwnership(address payable newOwner) external isOwner {c_0x0b167a52(0x6626439242a4e07e8ffb0f490b80d9f3655647fe7a3a169f1cdb08ff214a6904); /* function */ 

c_0x0b167a52(0x611e3a11ae8ce0a01491e203568a6de35f5f8606943ceb850b75e91cf3e913b5); /* line */ 
        c_0x0b167a52(0x254522ea6a214c3efd4efba584a9e1e0e86e675dd1e0e10f88be904170a83e04); /* requirePre */ 
c_0x0b167a52(0xa0975796ec9fd6ed95914dcc19cb0041059463587b5a1fa795f87b977e49ff3d); /* statement */ 
require(newOwner != address(0), "ERR_ZERO_ADDR");c_0x0b167a52(0x544b949d11a3d508060047ad5a4f9842719898f86299f9a315f8bebcde92c4f8); /* requirePost */ 

c_0x0b167a52(0x55b7aeff4095d6bbe4599597e2b7f4f1378b58ed3b32cc69979426e64c704716); /* line */ 
        c_0x0b167a52(0x58cb21faf543df8e0bb8b893d0614bd7b28432b23b56a90e2f7a81830cc21d4e); /* statement */ 
_owners[newOwner] = true;
    }

    function removeOwnership(address payable existingOwner) external isOwner {c_0x0b167a52(0x1a37b06a8a95ee91e291f97840e7183514848c8d4042f6008fb8d5011dbe9943); /* function */ 

c_0x0b167a52(0xb6075601ccda6af5092fcf38a7588a91be90eeab4692086ddcb55be3f107e19b); /* line */ 
        c_0x0b167a52(0x596654066e3bf12828ab2a1a2df18c051090aabf50089878631bb0aa27ce514f); /* requirePre */ 
c_0x0b167a52(0xe895025d8d11a364ca783d5c876450c13c4875ed2031ee182f7c01ffb7416841); /* statement */ 
require(_owners[existingOwner] == true, "ERR_ADDR_NOT_OWNER");c_0x0b167a52(0x5a350a4cdd461011b07002fb007943b49c0b46983943ecc5173ce679ddd81831); /* requirePost */ 

c_0x0b167a52(0x0451d25bc9f83ae03643b13db45e0abc5a1317fdbd6e1049de1a851db0a65989); /* line */ 
        c_0x0b167a52(0x9c333e3f90f9db3f295f24ba43e9a3e724befa0c862890fe588f77a22184cd82); /* statement */ 
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
function c_0x5e51bd03(bytes32 c__0x5e51bd03) internal pure {}

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

    constructor() MultiAccessControl() {c_0x5e51bd03(0x06186cae3d9aec97f03a0d7c6a8d11bb60d89e01cd9042a0b81f8834faf2386b); /* function */ 

c_0x5e51bd03(0x3910c50f3b329af42b3ba79e1d1ef24c9dc1cb46840b92af9b01279aa865a09e); /* line */ 
        c_0x5e51bd03(0x594b2e2289fd3f7a2faa29a8e69ca851c37c54ecbc188df3054b59eea2ff9fe2); /* statement */ 
openTradeCount = 0;
c_0x5e51bd03(0xc81d80ba28a8013069dc950af238b5e0e3c215b66b9020b38eb4004b7181b885); /* line */ 
        c_0x5e51bd03(0x3545153257d3ca322df103026634faee269508aa58af19bd475e01a8fce4a6da); /* statement */ 
totalCompletedTrade = 0;
    }

    // External functions

    /// cancelTrade -  To invalidate an already created trade. Can be called by both the trade creator or executor
    /// @param tradeId to cancel
    /// @dev changes the status of the trade to cancelled
    /// @return all true  if trade was cancelled
    function cancelTrade(uint256 tradeId) external returns (bool) {c_0x5e51bd03(0xb39deaf1058e03c74657df116b191caf2b301166ff2f7537c79a21bddc7f1e4c); /* function */ 

c_0x5e51bd03(0x8ab9ec8b26c8a987b56cacbd4917f77a0e164c26f298f0e88019d1a1ea980aff); /* line */ 
        c_0x5e51bd03(0xe6d2611387e766163806edd7d6981e9e43067d458cfbba37be2f6b516b5a1a3e); /* statement */ 
Trade storage store = _transactions[tradeId];
c_0x5e51bd03(0xdd2f7716729ac418dc4a73a1a85eff42dcd46023658f26cd47630044807890cd); /* line */ 
        c_0x5e51bd03(0xd307c8c83206cc4d34a5cc99abdd773c960e3c27703408fb51430c119939cba9); /* requirePre */ 
c_0x5e51bd03(0x5849703bf62b819a265068e11ab392848ec01b818cac86c79f59ad54dafc8793); /* statement */ 
require(
            store.tradeStatus == TradeStatus.TRADE_CREATED,
            "WEB3BAZAAR_ERROR: TRADE_STATUS ISNT CREATED"
        );c_0x5e51bd03(0x9a3c4597a82d39b9289cbd7efc7a4eab9a840b6bb26c1d9ae31b72c16650be9e); /* requirePost */ 

c_0x5e51bd03(0x82651a49b4806c1165d0001c44289fb2ff8a4511c0607714a5d37820c9e2ad58); /* line */ 
        c_0x5e51bd03(0x41ebf7a46cc7901163dbdfabbb32537d1f614bf44e32f391a1aaf378c7904904); /* requirePre */ 
c_0x5e51bd03(0x1197e8dbf08db358cf801c6231c14abd912edc7ac175d6c408b661e74c23df83); /* statement */ 
require(
            store.executor == msg.sender || store.creator == msg.sender,
            "WEB3BAZAAR_ERROR: EXECUTER ISNT CREATOR OR EXECUTER"
        );c_0x5e51bd03(0xf5345a843fb5bed2506cd416f22964a3ff9f9f28b1ae632a21aec03c0987cd21); /* requirePost */ 


c_0x5e51bd03(0x6f86b71778c7e4fb450192a31c344aaae45c61bc00a2b6d2e762765ce9b75c8e); /* line */ 
        c_0x5e51bd03(0xd8b20c499640d6d6fbcfbe725144b62031d7727fcd79908ac91eaa6d433e2e5f); /* statement */ 
removeTradeForUser(_transactions[tradeId].executor, tradeId);
c_0x5e51bd03(0x86d14d7461f42dda03edb63649f1b34909a2cbfda7b989689fd016356c1690f4); /* line */ 
        c_0x5e51bd03(0xb53a0f1ee912b65bcfcd77486ac29e6adc2b56cc3e5f9538d56e4b2f925830bf); /* statement */ 
removeTradeForUser(_transactions[tradeId].creator, tradeId);

c_0x5e51bd03(0x878c0f51fbbc7d0c93811eca65a863a573f767b3b7fd623a4c08fe2e7d31fd45); /* line */ 
        c_0x5e51bd03(0xc856f8f6352925b4545a27218b9f244f2c6b70731788ce515882b5cfdbe97076); /* statement */ 
_transactions[tradeId].tradeStatus = TradeStatus.TRADE_CANCELLED;
c_0x5e51bd03(0x6229205c1920cc8d82c4f73f0343a48f97f306ca41c6618fdf787d99a21c9766); /* line */ 
        c_0x5e51bd03(0xc4dd8fa379f55de753c832ccf24b894ec403f4e243f3d090b616538524c4c8ce); /* statement */ 
openTradeCount = openTradeCount - 1;

c_0x5e51bd03(0x8f1908e21de56bd6ebbdb27984d7f9b3318df35be3818dfa0f2dce4fedc83885); /* line */ 
        c_0x5e51bd03(0x0f950d061f9e5de1b821190a78eb25f50b2bd4a7205079a78b90124d8a70f932); /* statement */ 
return true;
    }

    /// executeTrade - to confirm a swap proposed by a creator counter-party. executor calls it to initiate the trade
    /// @param tradeId to execute trade
    /// @dev verifies assets ownership from both parties before swapping them.
    /// @return id of the trade
    function executeTrade(uint256 tradeId) external returns (uint256) {c_0x5e51bd03(0x85a4ab16a62707685d3d5146de2399d830586e4bbc347da2848cc1707e07683d); /* function */ 

c_0x5e51bd03(0x2d799d7c3b2716deb74d78d46dfd3128e7da95489dbcb8ffd1d83df9db541083); /* line */ 
        c_0x5e51bd03(0x305e0393645eef35316f89f264c193ccc688efadc28de47df35d119de12eb914); /* statement */ 
Trade storage store = _transactions[tradeId];
c_0x5e51bd03(0x9117edaa54bf7ac425b4729de5826845921a03c08aafaae631464e96c00d4b07); /* line */ 
        c_0x5e51bd03(0x016be87c0ebf5504ceb5c6249e61369cd3d996eae6816ca002ce78968e44b3b5); /* requirePre */ 
c_0x5e51bd03(0xf338da8f8bd7c25577554e736f91a6791ead1e49690eea1cd459a07188732bdc); /* statement */ 
require(
            store.tradeStatus == TradeStatus.TRADE_CREATED,
            "WEB3BAZAAR_ERROR: TRADE_STATUS ISNT CREATED"
        );c_0x5e51bd03(0x4f032bf6fe2b2c420b65d774c9410fb13f5ae61081afc00c76f06f90431b4a4f); /* requirePost */ 


c_0x5e51bd03(0xa78aeb911302ea44265179c98aa7aa7b8f3c0e1485ff4a84b3739e1868c59b17); /* line */ 
        c_0x5e51bd03(0xd2b02124783e95a62696357569b79795ebd96ac913a0a472febf27af8db87e73); /* statement */ 
address executer = store.executor;
c_0x5e51bd03(0xe2573bdd30af156689bb9a98a91824f4f831fb3d710ed0119eeb025017983868); /* line */ 
        c_0x5e51bd03(0x98657fc75b2189ad39f85acbe4c6227e074f318e4850b7145725d809bbe6ea59); /* statement */ 
address creator = store.creator;
c_0x5e51bd03(0xc90adc5f2a519fa1ddd4d4a6ebad5dfd27c04701df4c840951e2d03778340a0b); /* line */ 
        c_0x5e51bd03(0xa4e702b68a3b7abd80275d138b86c9deb08861432da4fb870323def0aa600481); /* requirePre */ 
c_0x5e51bd03(0xc6dd48fc97bd31b5e32d60a1fad53c4fabc56c4d4b5145d2a42d20f79b830ecc); /* statement */ 
require(
            executer == msg.sender,
            "WEB3BAZAAR_ERROR: CALLER INST THE EXECUTER"
        );c_0x5e51bd03(0x9e410d1e6bd419ef56701c79325481086a5809ff24cfe45c07109f1337a51dd2); /* requirePost */ 

c_0x5e51bd03(0xb75eba0efd26763294f84d18bc6efd465a134b093670e1cac6478add44139c80); /* line */ 
        c_0x5e51bd03(0x3119068ec6858f870178eb8ef066381c88364620dd10a97e0ddd5d053bd97534); /* statement */ 
TradeCounterpart storage tempSwap;
c_0x5e51bd03(0x5db243345ee8330d1d265d2773f9c0768c6e4eedfe50e50027f572639b208bc5); /* line */ 
        c_0x5e51bd03(0xb0ab57d33d3e5ae6ed73b0f87f18b942b14b73f0d968be79117a03c6fccae2ae); /* statement */ 
for (
            uint256 i = 0;
            i < store._traders[creator].tokenAddressIdx.length;
            i++
        ) {
c_0x5e51bd03(0x5a2ea8e005df24de2da4111e6fd9611669480647142d52f45d59899f6453bb33); /* line */ 
            c_0x5e51bd03(0xd3f8fe95ea038c82d200485c9018a9ed43ed8acdae98a41e58a8fc46fab6131f); /* statement */ 
uint256 tokenAddressIdx = store._traders[creator].tokenAddressIdx[
                i
            ];
c_0x5e51bd03(0x839faec5af0db8610e2751b7bdf3ba54be9dc9556562c039d9ac98e078fe1b7e); /* line */ 
            c_0x5e51bd03(0xe5d75748aebab3bde44df9a8b32b1de14729b50346495ad5fbef9b6dac7d058a); /* statement */ 
tempSwap = store._traders[creator]._counterpart[tokenAddressIdx];
c_0x5e51bd03(0x965850d691064c2f9eecbc9b43507c2bc736e08ce82a012aadbf81fb0e19a1a2); /* line */ 
            c_0x5e51bd03(0x1c1aac063afaa2fb759c01209c5dcabe3c7f69e7ff233747b0e65fb987d08421); /* statement */ 
if (tempSwap.traderType == TradeType.ERC20) {c_0x5e51bd03(0xf0b86dbffd9983d9584ecd1fdc3f2fcdcb2fefe86e88821f5c9d8f7aa5040492); /* branch */ 

c_0x5e51bd03(0x60156b04c4b888afdfb557a78353367c74cc60fdc37401592ba4defaeb7e1d67); /* line */ 
                c_0x5e51bd03(0xc32f4562a838fe03b13c8621967ad9ae14722d64f605ad2ff495a2d854f449c7); /* statement */ 
swapERC20(
                    creator,
                    executer,
                    tempSwap.contractAddr,
                    tempSwap.amount
                );
            } else {c_0x5e51bd03(0xd999f2e4090183efd21ab4f49fdcaeb2af619b5236f1312b8b040f04807b571f); /* statement */ 
c_0x5e51bd03(0x6b2f7ecdc5a2b492ca59e8e538cdd81f55717162fe26c6dce3a2ffe6768b16be); /* branch */ 
if (tempSwap.traderType == TradeType.ERC721) {c_0x5e51bd03(0x52e2e6db2ddf7685f841f7ad11b4301c1a05990f0d5830f4e0559a2d09f535b7); /* branch */ 

c_0x5e51bd03(0xef180a0e172f9a0410bb0ef7dc7ea038c10e92bbf672cba04366e039d86aecea); /* line */ 
                c_0x5e51bd03(0x11241a3246934c555f14ffe8ec88cbfce4c9da8a677c632579b814f0328ee1e3); /* statement */ 
swapERC721(
                    creator,
                    executer,
                    tempSwap.contractAddr,
                    tempSwap.idAsset
                );
            } else {c_0x5e51bd03(0x76d331926b1c41060d0d18789e854041d133b437254f75364bbb1542d8774b06); /* statement */ 
c_0x5e51bd03(0xf01306255579e26b050198570341e02c5b5fc385b3fa95f1bf1d2e5ab98b4a14); /* branch */ 
if (tempSwap.traderType == TradeType.ERC1155) {c_0x5e51bd03(0xdb9276a20d563860e89687a72c394ae52ef8657d1e461ec2b280799b4aadaa08); /* branch */ 

c_0x5e51bd03(0xf750dcd393ab6dc79f7c7c3962162428207f887b21e00baaff59f332c161d9fa); /* line */ 
                c_0x5e51bd03(0x2a0c6de8d0e2164436d82d1cfc146c283068a3c9a9cf81bb9c4d893be6d3ffb9); /* statement */ 
swapERC1155(
                    creator,
                    executer,
                    tempSwap.contractAddr,
                    tempSwap.idAsset,
                    tempSwap.amount
                );
            }else { c_0x5e51bd03(0xc57bd940d8c8c532d55cf92c1ab0758917e3f614bcec51648e95d125b6977b81); /* branch */ 
}}}
        }
c_0x5e51bd03(0xf352b12a86bb65f873af93094bab5c024992c86cd396dace6957a71a1e65b7a9); /* line */ 
        c_0x5e51bd03(0x78c262da913b1be7f3b8171cd8c76948e090aa272a51bca01a249080b58f5708); /* statement */ 
for (
            uint256 i = 0;
            i < store._traders[executer].tokenAddressIdx.length;
            i++
        ) {
c_0x5e51bd03(0x4b2aa33ff5d8b8060216c16ec9b1b1e11c4ec0a8e154330cfabe78bc17b3d3ea); /* line */ 
            c_0x5e51bd03(0xedb50084ddf5fa0ed52f83c18b384a234536d3fc53c2cb1f2ca0e20cd69d11e2); /* statement */ 
uint256 tokenAddressIdx = store._traders[executer].tokenAddressIdx[
                i
            ];
c_0x5e51bd03(0x9cf18e01b6ce684df54ca684275fba8451d724ce5f12d6fb1be6755533b56af1); /* line */ 
            c_0x5e51bd03(0xab775fde9e457904a1cd17f18aa8a9698fb1f032b66636c2c8ab0d54b3c37818); /* statement */ 
tempSwap = store._traders[executer]._counterpart[tokenAddressIdx];
c_0x5e51bd03(0xdd5c182a8aa08d76dd74d5ae2e7837d438504756fedffd280a8ec78cb2729b0c); /* line */ 
            c_0x5e51bd03(0x6165a68adf9f351b9e6151497605a1b48b3e3edb604e2956f1734441777577a7); /* statement */ 
if (tempSwap.traderType == TradeType.ERC20) {c_0x5e51bd03(0x70dba8fd946910f9da7f2710eec3cdb092998d166a61ed2f566a0df9e395cbb0); /* branch */ 

c_0x5e51bd03(0x70434e1309d1458ec5cb8ec95494042fb503daf6b25e5bcfbf55ce6808c0cc49); /* line */ 
                c_0x5e51bd03(0x5de1708b5d495d3577352392054bf9ddb478e0090944116feff063817a8c7907); /* statement */ 
swapERC20(
                    executer,
                    creator,
                    tempSwap.contractAddr,
                    tempSwap.amount
                );
            } else {c_0x5e51bd03(0xb7af5b102ef730c96f5415d79eb7d54c19af326752f58ae691bd73e59379fef0); /* statement */ 
c_0x5e51bd03(0xef51dec34c68802b8d23506de57f47d134785ffcce441366881c5c72e1862291); /* branch */ 
if (tempSwap.traderType == TradeType.ERC721) {c_0x5e51bd03(0x5013411b1f44e3cc0cc343e9a45581b9da3de857249ceb89faa7fb5635377702); /* branch */ 

c_0x5e51bd03(0x256ae3ef140a0d8a0cbc37a347198764794fb9a0c122566fa1146b625ff3cd92); /* line */ 
                c_0x5e51bd03(0x03cd976c3a1cfcf464297388febe48e0b85463df80e6577d164845239e30511f); /* statement */ 
swapERC721(
                    executer,
                    creator,
                    tempSwap.contractAddr,
                    tempSwap.idAsset
                );
            } else {c_0x5e51bd03(0xa4b2cb4535073fd9b8b0c27cd9e9f525c8c04213222b98c43fe549702fc4d3c1); /* statement */ 
c_0x5e51bd03(0x47565400d5fbeadf37dbfcabaa7168444cfe68b2246b30e5055b211be759d0a3); /* branch */ 
if (tempSwap.traderType == TradeType.ERC1155) {c_0x5e51bd03(0x64e9240971b42de96d3278702d39b115ea2ff8e7b2fad5061ebccb44042687b3); /* branch */ 

c_0x5e51bd03(0x40d298a13d843d5820d055f6ac7269bf2abff714092034cb54b09288aa800024); /* line */ 
                c_0x5e51bd03(0x080e98d2e97000064a64a30bab7e775e020777b6110e2ce9de0dcc910f3c5bc4); /* statement */ 
swapERC1155(
                    executer,
                    creator,
                    tempSwap.contractAddr,
                    tempSwap.idAsset,
                    tempSwap.amount
                );
            }else { c_0x5e51bd03(0x8bcf922a69db6cac29ef5202425baa68db4da609d5d73d6136a5caa54b23daec); /* branch */ 
}}}
        }
c_0x5e51bd03(0xb2be664ae0b9fa02fa0a640353b116377076036b04d8b2668c2c842c871949a9); /* line */ 
        c_0x5e51bd03(0x7e1837691da0f263bd2d92bf737852c4e15498ee1d99c785491465af26808cc1); /* statement */ 
_transactions[_tradeId].tradeStatus = TradeStatus.TRADE_COMPLETED;
c_0x5e51bd03(0x1901ea1d72ed1655eef1f169b603dcfbf2b6c5509ab6523e8fdd00d12d5c2d28); /* line */ 
        c_0x5e51bd03(0x438e8faacc9a30cb944713232aa0031ceb9094595a79626ae02074d7319275f6); /* statement */ 
removeTradeForUser(msg.sender, tradeId);
c_0x5e51bd03(0xc635b34504357099a76671dfab42ba320e16f8139fe0ecfd6bdb791fcb2da26e); /* line */ 
        c_0x5e51bd03(0xb72cce96176a26e53205ed3b4e01053b8dc1f73ac801d1631f2eb87b78e9da03); /* statement */ 
removeTradeForUser(_transactions[tradeId].creator, tradeId);
c_0x5e51bd03(0x23fd236185eca9c5ce0f8f6be4cd8f587b554327651b0311ad7a1ae90620db23); /* line */ 
        c_0x5e51bd03(0xb94b0930d78318fe5e2aa36a714c306b9e9d7c272ff8c224e67ef523781ec431); /* statement */ 
totalCompletedTrade = totalCompletedTrade + 1;
c_0x5e51bd03(0x2a5a0484241d3edbfe0a62370189bf020b3d42ee181d3b2ec9c33796b9eecee9); /* line */ 
        c_0x5e51bd03(0x0ddb6ad67a3d594a85d1930b3a2144737a4979058846c0f0575749d8c942a844); /* statement */ 
openTradeCount = openTradeCount - 1;
c_0x5e51bd03(0xf5429c8c81fcbe4d4a1cbe155ba8e59e3bf3ccd537d6818041161ef7c5530be3); /* line */ 
        c_0x5e51bd03(0x478b9460cb866aee2a3cdb56f25fe03f3e9bcd86d5dfb4e6ae7c221e5d9e7a67); /* statement */ 
emit FinishTrade(msg.sender, tradeId);
c_0x5e51bd03(0x1c53249f1dd13150e382cbeb2dead5f5bce880e325d3166a25ba43762d5da732); /* line */ 
        c_0x5e51bd03(0xc178ec644b96678e7d506212db8540d54cf118fbe30de8fedf8befb137448805); /* statement */ 
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
    ) external returns (uint256) {c_0x5e51bd03(0x0989ef4436ccc0da4de9a293b01810610dfd5f4efa03dcdd2886082a887f1709); /* function */ 

c_0x5e51bd03(0x7ec6f07b098e6259b080d22687739796897e745800efa2882b4454355e6750a5); /* line */ 
        c_0x5e51bd03(0xce266ef04e3403d6b984b62e5f9acd0c6e566f661f39f8948406e236efa013a2); /* statement */ 
address creatorAddress = msg.sender;
c_0x5e51bd03(0x54630407c3b1d797a9b2a37d7788319309562c33e8811ed5aa4024da39892249); /* line */ 
        c_0x5e51bd03(0xd72abcda38607e9dc49f3489fe39366efd2bae79fa38f85ccc936c1233a91344); /* requirePre */ 
c_0x5e51bd03(0x48bc429878b8980b083e61053206d3c45905b74ac62e84359ba9e25c72f7b608); /* statement */ 
require(
            executerAddress != address(0),
            "WEB3BAZAAR_ERROR: EXECUTER_ADDRESS_NOT_VALID"
        );c_0x5e51bd03(0xd3d4b61943ae92e20f238f084e3d9c1b6a71c151ccd64a2d5bcc227893f49945); /* requirePost */ 

c_0x5e51bd03(0xbdfeaad49e99d89f91165bd254b27ff246500495d83ae382636467bf7514007f); /* line */ 
        c_0x5e51bd03(0x0ce69a68da56605f647c37d269c927b5e4c8d3b80241be269cda36367b47a367); /* requirePre */ 
c_0x5e51bd03(0x4614f81e2f2de117f27657ae1c9ed7b2d3f66381b2d47197a37559a46eb217f3); /* statement */ 
require(
            executerAddress != creatorAddress,
            "WEB3BAZAAR_ERROR: CREATOR_AND_EXECUTER_ARE_EQUAL"
        );c_0x5e51bd03(0x1fd3fe15b2300d6f987e7eb741b6895a9d9336bc1f27b1ae686bf594302e752a); /* requirePost */ 

c_0x5e51bd03(0x5f15ad76f6fd24edc4fd9862ea6c42ea46579086816a8761556d2caca217dc95); /* line */ 
        c_0x5e51bd03(0x909fe58e208885fffc7c59ee3db7647f84f1abe9805eaccea29de059be97a12d); /* requirePre */ 
c_0x5e51bd03(0xd9eed5974e7090ff3ac1f1c3199cea9dcb93a20c2b5197807953b70adc744991); /* statement */ 
require(
            creatorTokenAddress.length > 0,
            "WEB3BAZAAR_ERROR: CREATOR_TOKEN_ADDRESS_EMPTY"
        );c_0x5e51bd03(0x9fdf1536397f91eed7cd64248079cb4528303218c8728318915ae5edf290a608); /* requirePost */ 

c_0x5e51bd03(0xf1111382deb0f8cfe2518ca0f16ebc91cde63d843808b4fc484d4c0d83e8a0d3); /* line */ 
        c_0x5e51bd03(0xca0728c17d66327635c7b017cf27fdee2b9eba327207b0cb52823002c352474c); /* requirePre */ 
c_0x5e51bd03(0x1502f21f4e45e43cc8b14241050af3f99c8f5970d64ce78533898bfa9bb230bf); /* statement */ 
require(
            executorTokenAddress.length > 0,
            "WEB3BAZAAR_ERROR: EXECUTER_TOKEN_ADDRESS_EMPTY"
        );c_0x5e51bd03(0x0716f92878abb4e25b306e3caa4726812f5352a978636c7c8f6489d7bc1f8fe7); /* requirePost */ 


c_0x5e51bd03(0x1606e375c9df609732c4ae5f4ae3b0c1f8d370aa2ade09cfc9feb1299892a3f0); /* line */ 
        c_0x5e51bd03(0xb29531fd7ef5b5e30144810f0284763a4db080d9784dd1a1a2af68293d72d6c7); /* requirePre */ 
c_0x5e51bd03(0xeb0a185cb434e63b732cfab5326665c30cbd15af7a0e45bdd59bd272ec05f4d0); /* statement */ 
require(
            creatorTokenAddress.length == creatorTokenId.length &&
                creatorTokenAddress.length == creatorAmount.length &&
                creatorTokenAddress.length == creatorTokenType.length,
            "WEB3BAZAR_PARMS:CREATOR_PARMS_LEN_ERROR"
        );c_0x5e51bd03(0x89ca0df0bbb4ba8e083aa7877692491cc9ea43f112ad219cb7f82850b054c8a0); /* requirePost */ 

c_0x5e51bd03(0x2a2ffec25b3190b19cea61d957037c04b2e5b6e85aa5d3612df8bca16d7f5bd4); /* line */ 
        c_0x5e51bd03(0x05895e57cc83d823b1b3c0a1913cab9748752037b660512c83b3352646354f40); /* requirePre */ 
c_0x5e51bd03(0xb340f2d9a2ba0df74e851cb63d41968dc2720104407025f87fd067e7da10b413); /* statement */ 
require(
            executorTokenAddress.length == executorTokenId.length &&
                executorTokenAddress.length == executorAmount.length &&
                executorTokenAddress.length == executorTokenType.length,
            "WEB3BAZAR_PARMS:EXECUTER_PARMS_LEN_ERROR"
        );c_0x5e51bd03(0xa4ace26fead648acc6c321c62fa1b53950d97dcca56459a07b85b70cea55bd07); /* requirePost */ 


c_0x5e51bd03(0x909c4eccc65ed8bfa94e306890e93582b89f6c82c1deec549e0f08c6878b092b); /* line */ 
        _tradeId++;
c_0x5e51bd03(0x029bc9aed6a367f6fba7edfcdb5ce78ec4054021607438eca969c0bbfb2dd02e); /* line */ 
        c_0x5e51bd03(0x77ccc8c11f99998334c0ee3005dc8c340b046906875eaffb3e5631bd4ceb197e); /* statement */ 
_transactions[_tradeId].id = _tradeId;
c_0x5e51bd03(0xfd602bb3584d740bfb461d7ee5e260600a852b6ee7f58f560a8c37e42d13fa10); /* line */ 
        c_0x5e51bd03(0x0badc94f6b8c397297483860e6802d292860de01407a821297d66b3fc20a3af4); /* statement */ 
_transactions[_tradeId].creator = creatorAddress;
c_0x5e51bd03(0xa49dc64c119c8a682a94f223874e71c993b3be57e3f98b953a94d783b4aa5548); /* line */ 
        c_0x5e51bd03(0xa8675eabd2e1cc764bf18161cc009fc68686a876e7865bbea4eb9d76e5bcc8d9); /* statement */ 
_transactions[_tradeId].executor = executerAddress;
c_0x5e51bd03(0xbac9865667e9643f1484ae53f6a124b4b9f7340af0a535091f9b3938ca162449); /* line */ 
        c_0x5e51bd03(0xc1649f370fc0b7b2289c8c50d5b9a345edd82dac2777bb49f89a98d0ed230a46); /* statement */ 
for (uint256 i = 0; i < creatorTokenAddress.length; i++) {
c_0x5e51bd03(0x404d1fa7159cb1799c32c78ac8bf9d7303583c87a85fed97bb1b903fa2aa0b11); /* line */ 
            c_0x5e51bd03(0xa2d3ff6554d4ee303c8fd2a1dac557fed47a0272430d7e7052d684d5b674f3c0); /* statement */ 
verifyTradeIntegrity(
                creatorTokenAddress[i],
                creatorTokenId[i],
                creatorAmount[i],
                creatorTokenType[i]
            );
c_0x5e51bd03(0x398c64e67d00bdefdc8ac17af2e050d9ff4f1ffdd0082f9695cf349b256c35ff); /* line */ 
            c_0x5e51bd03(0x8d788a1387cade97ae97a4d25847505c4c0cd934c0884adf4671aaaf9d9ddcc7); /* statement */ 
if (TradeType(creatorTokenType[i]) == TradeType.ERC20) {c_0x5e51bd03(0xd3d1ade9e7db7abe016f0aedfb88f2e68cc8f807e72f052df1708cb016a41ca4); /* branch */ 

c_0x5e51bd03(0xd8f43c078803f11b570499feba6589e34774a8e3745807cd1c8c9a4211504bcf); /* line */ 
                c_0x5e51bd03(0x73883b5ed20f15351a0f594ee914944ef96cca5f1a6cfcc2b83d7293ed3e60eb); /* statement */ 
verifyERC20(
                    creatorAddress,
                    creatorTokenAddress[i],
                    creatorAmount[i],
                    true
                );
            } else {c_0x5e51bd03(0xa1554273a18ff82733f73657cc0ccde5da6ba2498b091946335776b5ef4f673f); /* statement */ 
c_0x5e51bd03(0x21d13861e466bd99a7df961d2e0c79cafdea6cd2a5d5d7e6a9b8998386f4967e); /* branch */ 
if (TradeType(creatorTokenType[i]) == TradeType.ERC721) {c_0x5e51bd03(0x090fd6d9652bd7c0bd3c377ec366f65d14d5bc8ad01ac350a1f8b33a16420104); /* branch */ 

c_0x5e51bd03(0x7c3946525c1608f51a8ac8a348ab31ea45b737320280e55875dee854275b7b72); /* line */ 
                c_0x5e51bd03(0x45bdd65ef2daafd4f598c5384f9bd5387b6de671533c8638ce3300eb40c8cc66); /* statement */ 
verifyERC721(
                    creatorAddress,
                    creatorTokenAddress[i],
                    creatorTokenId[i],
                    true
                );
            } else {c_0x5e51bd03(0xdd41d4fd64e356b395c62b5a5000d5fa22c4f469f8ac0c04f1bd354fc27ec08c); /* statement */ 
c_0x5e51bd03(0x7f2c99cd1efb1cfa4c802e4866e73716fd2495ea50ef6d8c2c401014004fc807); /* branch */ 
if (TradeType(creatorTokenType[i]) == TradeType.ERC1155) {c_0x5e51bd03(0xf85f5ab894a05bab48f42aca43150b3956a2a1183b2640b7f785adaa53ecfbe2); /* branch */ 

c_0x5e51bd03(0x18c22cf4a0e956b15b3fa36269c33bfbfe0a08f77a9566ac87d8728c161555b1); /* line */ 
                c_0x5e51bd03(0xad3759b59c6f4a90efd44516dc6f7c4acf1a79201ec8c86f722f5d7dbd3a861c); /* statement */ 
verifyERC1155(
                    creatorAddress,
                    creatorTokenAddress[i],
                    creatorAmount[i],
                    creatorTokenId[i],
                    true
                );
            }else { c_0x5e51bd03(0xd4578c1fa779af8d774669ef7d9f6d8c1063617aaead937b5f6ce9e48df7e9fc); /* branch */ 
}}}
c_0x5e51bd03(0x6332514b684522f6d5bb4a1a2de727577260a7eda77ae5f8d043d9df95589858); /* line */ 
            c_0x5e51bd03(0x8359a0aafb9536c19f0236ed49fecddb25291d94ad1645afdf9f9a552afc0ddf); /* statement */ 
_transactions[_tradeId]
                ._traders[creatorAddress]
                .tokenAddressIdx
                .push(i + 1);
c_0x5e51bd03(0xaee132b2bdad5d5b8a1778d62739ef2ef93dae591252de9dbb3a0c61cb56e530); /* line */ 
            c_0x5e51bd03(0xba4dbe7e1fb6a972a020eb6b4f19abc4ca9ef08ef8bd78862bf30ed7747f38ba); /* statement */ 
_transactions[_tradeId]
                ._traders[creatorAddress]
                ._counterpart[i + 1]
                .contractAddr = creatorTokenAddress[i];
c_0x5e51bd03(0x2ef9f856d77afed6a2c289b4693c9e7fce95ebd65ee02845af8e4fbe0d5f246c); /* line */ 
            c_0x5e51bd03(0xa5ff34f760a7f32b20c50a6001d61b485a1e597299ff010a7dc83828636262cd); /* statement */ 
_transactions[_tradeId]
                ._traders[creatorAddress]
                ._counterpart[i + 1]
                .idAsset = creatorTokenId[i];
c_0x5e51bd03(0x7024c8ccd157d2a3dea4a05780984df10d27e2519154b08a95bc8bc0d32007bd); /* line */ 
            c_0x5e51bd03(0x094b144edc9b648387bfa5d4f876dd5c6bdb70c4f4e70a695dc5505dab6e8482); /* statement */ 
_transactions[_tradeId]
                ._traders[creatorAddress]
                ._counterpart[i + 1]
                .amount = creatorAmount[i];
c_0x5e51bd03(0x6296061d3d31caa180d4bb0a2475c5cf1aab699f9b8c4c73c187046f2b4d97a8); /* line */ 
            c_0x5e51bd03(0x4f16e2033dd1a345e2d4afa740f32d0629eab542fe81cbb64efeac2f091b103a); /* statement */ 
_transactions[_tradeId]
                ._traders[creatorAddress]
                ._counterpart[i + 1]
                .traderType = TradeType(creatorTokenType[i]);
c_0x5e51bd03(0x46643161b59c83d7893847f58662c5b56a9d35bae10c785370cb4748f347d4ec); /* line */ 
            c_0x5e51bd03(0x7ed6922c4569d8bcdc48e7324776a6789ffe595bf0ccc20f55b92e28a49944a3); /* statement */ 
_transactions[_tradeId]
                ._traders[creatorAddress]
                ._counterpart[i + 1]
                .traderStatus = UserStatus.OPEN;
        }
c_0x5e51bd03(0xb26da4eddcb07089c77414ff69ea2d0014b02cd1a48f3b0df1a682ec4d6b6824); /* line */ 
        c_0x5e51bd03(0x5992f51f5e0c0274ceaa69a4816ddebfb4fb4622fb6b3b0b163825451ac35411); /* statement */ 
for (uint256 i = 0; i < executorTokenAddress.length; i++) {
c_0x5e51bd03(0x943f357542097c612fddd5b72bfe1a9b66e571b414e4d4274cfe40f746c22a83); /* line */ 
            c_0x5e51bd03(0xbf9706f0d5a64f68b0331172a97a79e146157eeafa9cbc34ccb512b9d1754ec5); /* statement */ 
verifyTradeIntegrity(
                executorTokenAddress[i],
                executorTokenId[i],
                executorAmount[i],
                executorTokenType[i]
            );
c_0x5e51bd03(0x7eab4f6ceeb655e2a27febd7e4848867aff428955401b10c0a7b90fdae7811b3); /* line */ 
            c_0x5e51bd03(0xfbeb844ff61fd44a5d71cad25cfb8408d656cadce91072685e8b03067cb82732); /* statement */ 
if (TradeType(executorTokenType[i]) == TradeType.ERC20) {c_0x5e51bd03(0xbd712ec2cc21b2aab0cf7add6aba61db8472601e0e14036a1e283881814f3d7c); /* branch */ 

c_0x5e51bd03(0x986d5a231043767d4c7b5e51b15740295124410cc9f37ed1eb687575775632b0); /* line */ 
                c_0x5e51bd03(0xd2808d9f93ac2162e77a5cfcd121cd270c636fca57cd1028719ae0844b036f8d); /* statement */ 
verifyERC20(
                    executerAddress,
                    executorTokenAddress[i],
                    executorAmount[i],
                    false
                );
            } else {c_0x5e51bd03(0x540a27a3fd6da533f513af57ad7dd80c264b586402e6121215a888479dff9089); /* statement */ 
c_0x5e51bd03(0x3d6e34a4d75873be2f5587e9e2912d30172cfe042d93213f671af91ede721d88); /* branch */ 
if (TradeType(executorTokenType[i]) == TradeType.ERC721) {c_0x5e51bd03(0x40940e33024bfbc3e62522cbf1c0e4a064b516588c7b187d1c4d3f7861feea72); /* branch */ 

c_0x5e51bd03(0xc7c35f49b886da5cd322f62793f1db9681dbd3d9596c8d5b190a719480b7a5c7); /* line */ 
                c_0x5e51bd03(0x1b4a0c75682e26b3c453f02f70a4e41f58e8f029d17e4d94e9f2b09c6a031f56); /* statement */ 
verifyERC721(
                    executerAddress,
                    executorTokenAddress[i],
                    executorTokenId[i],
                    false
                );
            } else {c_0x5e51bd03(0x358769efa53add56a1763116101e944ab46b189319836d301930eb8ce710e374); /* statement */ 
c_0x5e51bd03(0x411d7f899819579c9df9e0c1de1a40c7cee44c094edbbddb4bee57a2cc6b8dfe); /* branch */ 
if (TradeType(executorTokenType[i]) == TradeType.ERC1155) {c_0x5e51bd03(0xd42401474f54fee30a5d1743dacb01e33d4537a71ae9a91634fe908a24ff2a04); /* branch */ 

c_0x5e51bd03(0x9d79c4bad7c795b181d0fcb66b501fc2522860bfe94c29d316bb7cb12d05f896); /* line */ 
                c_0x5e51bd03(0x534aefbb3ea3f28500516008ba7f8c25aa86d1968de158e0236e89469c89bd9f); /* statement */ 
verifyERC1155(
                    executerAddress,
                    executorTokenAddress[i],
                    executorAmount[i],
                    executorTokenId[i],
                    false
                );
            }else { c_0x5e51bd03(0x87192d09d97441fc2f8493f6337c04e3a15b645fa1f875302acf8b86cfaac7f8); /* branch */ 
}}}
c_0x5e51bd03(0x84d506c0aa9cfeba3bd54b37c70bb641e6c97ee1104b8404f1e4e33886f9f2d5); /* line */ 
            c_0x5e51bd03(0xd316a0750f295fe40d0cb2eae988c0f1b67d3964dadb0e6c38913007559251c6); /* statement */ 
_transactions[_tradeId]
                ._traders[executerAddress]
                .tokenAddressIdx
                .push(i + 1);
c_0x5e51bd03(0x8dd927510fc7b51362bbf4c2f73596bd79eef1b5cbf01dcdf88b88d9b0085952); /* line */ 
            c_0x5e51bd03(0x8cddb666c0651af6ec6229c57904d407e052b3593f44467c6f0d24d9afc092fc); /* statement */ 
_transactions[_tradeId]
                ._traders[executerAddress]
                ._counterpart[i + 1]
                .contractAddr = executorTokenAddress[i];
c_0x5e51bd03(0xe3dc5f0ebc554edaa0c07cb3529c9df64deb08726404a5cb8bc4eaf259225c8f); /* line */ 
            c_0x5e51bd03(0x6d62de9017926f0175147d516438410158851a01aef2af6631e3c678250cc899); /* statement */ 
_transactions[_tradeId]
                ._traders[executerAddress]
                ._counterpart[i + 1]
                .idAsset = executorTokenId[i];
c_0x5e51bd03(0x41af15519067e8e70ce556b8e51ec23a243ba69efd4094d61d79d74f3622c0ba); /* line */ 
            c_0x5e51bd03(0x368f37551c83502bd2d8be736896164da643758ec2d2f6cf9eaef9435cd31b27); /* statement */ 
_transactions[_tradeId]
                ._traders[executerAddress]
                ._counterpart[i + 1]
                .amount = executorAmount[i];
c_0x5e51bd03(0xd983fad81bf38181f2687761db62e5bcc519c7766f4d4efe69978bf419a9fa6b); /* line */ 
            c_0x5e51bd03(0xf9894d694b9ce3e7c15915ce9e8ccc1a4be856a5efa23c998e9cf07199cba891); /* statement */ 
_transactions[_tradeId]
                ._traders[executerAddress]
                ._counterpart[i + 1]
                .traderType = TradeType(executorTokenType[i]);
c_0x5e51bd03(0x6eab5dde0db9d2b15dd5367a663f9a42581736ca5987716459c18be4d260e474); /* line */ 
            c_0x5e51bd03(0xdc28bd920eb23da4e413bcecb79848157b92ee43e6e10f7968bf4daa580378c1); /* statement */ 
_transactions[_tradeId]
                ._traders[executerAddress]
                ._counterpart[i + 1]
                .traderStatus = UserStatus.OPEN;
        }
c_0x5e51bd03(0xe84d27349d61c9acd9eeb0e0a1bd3bedd89a846753311346523c7f097680c30e); /* line */ 
        c_0x5e51bd03(0x789bdba9752f9009063db53c79f8a62b21b2ee2c91e281353fd614197ffc6a4e); /* statement */ 
_transactions[_tradeId].tradeStatus = TradeStatus.TRADE_CREATED;
c_0x5e51bd03(0x57a8502f471e4c281e39a661c897530775ef5dbffdabe47495735fe03267b78c); /* line */ 
        c_0x5e51bd03(0x481a720d4f1c01463aaec49b49299424783a0b7f1ca2a1f5157a1146d121f01d); /* statement */ 
_openTrades[creatorAddress].push(_tradeId);
c_0x5e51bd03(0x54bcf0cb9336b90ef494886cb1635980858e60a1a2b2c9b7023c1d1e755b8337); /* line */ 
        c_0x5e51bd03(0xb0ee3f20e082f00550d21958f768c2435739209c1e9e597f438f8c88d8b715d3); /* statement */ 
_openTrades[executerAddress].push(_tradeId);
c_0x5e51bd03(0x3caf7723faf03bd941962b508fdc57ff1c9747bba2e7898494d25c9016f6df93); /* line */ 
        c_0x5e51bd03(0xbc4216283dce30714e00a61700216057594353c53e3ad3896a458c6090985fa4); /* statement */ 
emit NewTrade(creatorAddress, executerAddress, _tradeId);
c_0x5e51bd03(0xcc95098a6dd14014609633b5ec2f60da374837114306e015cbb5033de95d44ce); /* line */ 
        c_0x5e51bd03(0x87f04f786722b2d84cf61dd51e649616ced524d9b51553ba8e2893ad2ed4a083); /* statement */ 
openTradeCount = openTradeCount + 1;
c_0x5e51bd03(0x1ef9c368afb22e9eac644c7f7a7f4c302a786840c78a235b8a292e4d8378b4a2); /* line */ 
        c_0x5e51bd03(0xae9c8bcf75e22ba68bad716e7ceaa7275167cd9eda74390667946a6b8d9535d8); /* statement */ 
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
    {c_0x5e51bd03(0x90dfbcaefbb8f6b06268cd57dd01a43a063bf40b81c878f0f25637a268e21c23); /* function */ 

c_0x5e51bd03(0xc9b509ff6eea298ee530389782673057e5c361e576e7b17583820ac2c915c363); /* line */ 
        c_0x5e51bd03(0x33063944a6f8893d28b7ecc8c937fa4cf58c3df640ff4e5325f6828225869212); /* statement */ 
Trade storage store = _transactions[tradeId];
c_0x5e51bd03(0x27edc4e7ad001a51d95cd1b1b12388947e4c435de38ed3955f736f5ec5faa273); /* line */ 
        c_0x5e51bd03(0x0a029970e2ec7a24849a7ff5783eb61bea45095046ade12c7df80c2ebb5349b2); /* statement */ 
return (store.creator, store.executor, uint8(store.tradeStatus));
    }

    /// getTrade - this method returns data about the trade based on tradeId and user wallet
    /// @param tradeId to obtain information
    /// @param userWallet to check trades for that wallet address
    /// @dev indexes internal sctructure and information based on tradeId and wallet address
    /// @return arrays of tokenAddress, tokenIds, tokenAmount, tokenType
    function getTradeWithAddress(uint256 tradeId, address userWallet)
        external
        view
        returns (
            address[] memory,
            uint256[] memory,
            uint256[] memory,
            uint8[] memory
        )
    {c_0x5e51bd03(0x68e3ac941569a8fabaa0a9368b81ec8b4cd5fb257751a7fe2da0563553d13937); /* function */ 

c_0x5e51bd03(0xaebcd5584045afb76f86e304762bbe21ddfff39f23d438fab63f15c63ee58b9a); /* line */ 
        c_0x5e51bd03(0xe219a32e87c6c1847835c0dc1a0411c6d4c4dba35d7cf56bcf9fab5e33c00024); /* statement */ 
Trade storage store = _transactions[tradeId];
c_0x5e51bd03(0x3a9d448c8653fe1ce504e05f3ac9218a1b00e4efcfbd95012c3a345976277ae0); /* line */ 
        c_0x5e51bd03(0x9b92c9a7da5c7ad1745cd1919ce5d79da3d1fa1ab47dd5ab812fac8d5d635251); /* statement */ 
uint256[] memory tokenAddressIdx = store
            ._traders[userWallet]
            .tokenAddressIdx;

c_0x5e51bd03(0x38277b83af21f48bc1870e1ce19c4d8aed3686c2fe74baec48d0e940d7f8af42); /* line */ 
        c_0x5e51bd03(0x5fb8bcdbb54090e1de4107078efe2ba43ea4b828bcfa784f9f72a3a3dabe155f); /* statement */ 
address[] memory _tradeTokenAddress = new address[](
            tokenAddressIdx.length
        );
c_0x5e51bd03(0x875743d6c5a24e66e1d30c3baa1a1f23638324bef0eaca3cffdc11a18a562af9); /* line */ 
        c_0x5e51bd03(0xf7c350ecef00daa126690d5916799f332db2aa5228b372f18434e67c824fba15); /* statement */ 
uint256[] memory _tradeTokenIds = new uint256[](tokenAddressIdx.length);
c_0x5e51bd03(0xe1ba69266b58cadfd8a9d2d5bd6f3ba08873eaffe873f289ee07ac2c6aacfe58); /* line */ 
        c_0x5e51bd03(0x007bdf1040c77ef4d0f82cf3e386671efffa70e014a3ee08001035456bdf104e); /* statement */ 
uint256[] memory _tradeTokenAmount = new uint256[](
            tokenAddressIdx.length
        );
c_0x5e51bd03(0x8c4a9b1f6269400732b46cfe5bd043467be880462072ec49c8cc5a6c41a9effb); /* line */ 
        c_0x5e51bd03(0x2a4d3d132459aec8db03d3ba212b4ecd1e1e944da3f525d2285b2735a5969eec); /* statement */ 
uint8[] memory _tradeType = new uint8[](tokenAddressIdx.length);

c_0x5e51bd03(0x6139d7399825c564646e6673bbb8bb5669f008deef913fecfc18fbb710c8dcf2); /* line */ 
        c_0x5e51bd03(0x002136380d1181465b31f46454c5a5a4a1a1e467248f1ba758a3e7e8cd02ce43); /* statement */ 
for (uint256 y = 0; y < tokenAddressIdx.length; y++) {
c_0x5e51bd03(0xb3a799bfd933116fef0e14c192dd4154729a4cf5420526f2194e6b20eb00af4c); /* line */ 
            c_0x5e51bd03(0x78efb8e5e4518a383f736ddb87da5d2ef4ad30610793e6b555524391df8c7289); /* statement */ 
TradeCounterpart memory tInfo = store
                ._traders[userWallet]
                ._counterpart[tokenAddressIdx[y]];
c_0x5e51bd03(0xfa6dbf6e344c85bec9df56f7449c929198f3f1e3d7493487bbf753b99fe56b6f); /* line */ 
            c_0x5e51bd03(0x68c9b8fef86e3244eb95b3c706bf8370af5042091262f698973067a58b7d4ec6); /* statement */ 
_tradeTokenAddress[y] = tInfo.contractAddr;
c_0x5e51bd03(0x1adc0f7b4b898a72bff161f0a9b8bf5066bebb1c9688a856be03a04e23e08def); /* line */ 
            c_0x5e51bd03(0xe19cd3cb09efd4023151ef899b9dcc18a89331f1ed3f8b88d334182114422040); /* statement */ 
_tradeTokenIds[y] = tInfo.idAsset;
c_0x5e51bd03(0x1d61f17b28cfd9addada3f88c598c096ee7d40438a6b562fe920f97f0858e22b); /* line */ 
            c_0x5e51bd03(0x5678238cac3a9d307bb42b1e8004015f7a3551fa0484489906f5684eb10c7ce9); /* statement */ 
_tradeTokenAmount[y] = tInfo.amount;
c_0x5e51bd03(0x17f9efae80f2df2d79770634dac96289ebc461180be51860938e52904756d251); /* line */ 
            c_0x5e51bd03(0xc62595da5e9713844d7abdc72ae952eb04eed3d763bc6cd00aeeb709d0902213); /* statement */ 
_tradeType[y] = uint8(tInfo.traderType);
        }
c_0x5e51bd03(0x959277c38b88761f51c38a4e5a2dd8bd423f9585cb57851b4b40bad0bed37d27); /* line */ 
        c_0x5e51bd03(0xdf7529a942bc8ba7b9d2f98786ccd4af4d54b475a9b86c16aa210716c39d7a3f); /* statement */ 
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
    function tradePerUser(address u) external view returns (uint256[] memory) {c_0x5e51bd03(0xaa96b713a91b295f4fe2f86fd1f6c5768d0f06e1f47f63fd4fb9dd8a86200564); /* function */ 

c_0x5e51bd03(0x8d745c1088b7096576689b16e87a56f8ea77022f5b3613e5785ef9ffdef309f3); /* line */ 
        c_0x5e51bd03(0xe95ea4590e4d2a1f1b0840c4186bf188ffb94ec94dc1876efe26b211676703bd); /* statement */ 
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
    ) internal view returns (bool) {c_0x5e51bd03(0xf2f9f954a83b9529da6f978b75fae2d2834e33a668bcc245b1b954e66d37cc1d); /* function */ 

c_0x5e51bd03(0x79191f862d628e64abe6353f097e95293d5554f15dd6a4b177083b82fbfc5e2a); /* line */ 
        c_0x5e51bd03(0x2cbc4d83542f721851aca6b5f2ac00277ce141acfcc7523e2f340bce8bc3e416); /* requirePre */ 
c_0x5e51bd03(0xe3649b30a390feefedd48c985e6823d8502e8555f25d877243d927180ba5fb32); /* statement */ 
require(
            from == ERC721(tokenAddress).ownerOf(tokenId),
            "WEB3BAZAAR_ERROR: ERR_NOT_OWN_ID_ERC721"
        );c_0x5e51bd03(0x4eed99d20979e5932d99522d58be613eb8528732c2a652a1938bf457c8c79a63); /* requirePost */ 

c_0x5e51bd03(0xf9b605dfa2d456d46ae75c5383c17ad25a991cd36e58e71ce19579d4d3613ecb); /* line */ 
        c_0x5e51bd03(0xf82e9aad0ab53ecf0f24c8dbfbda756d4a518aaf5dfdb79490bfd7f66810ddd6); /* statement */ 
if (verifyAproval) {c_0x5e51bd03(0x4a9971660cadcbaf04983cfe8b13b4c6be5b268aa98f6afa2329e2c901e94868); /* branch */ 

c_0x5e51bd03(0x6af036ce230b2640790ad1854d5be4e7126b733e43f366b96a305e877148d433); /* line */ 
            c_0x5e51bd03(0xfd7bbe1d91526d2b121f360596122d105737e9d41900c6e8f3c4ccdf4eece778); /* requirePre */ 
c_0x5e51bd03(0xa8c6cb0dcaa9a43cde93e532ec1303072c176e8cb967fb6620c27acaf0dbbaca); /* statement */ 
require(
                ERC721(tokenAddress).isApprovedForAll(from, address(this)),
                "WEB3BAZAR_ERROR: ERR_NOT_ALLOW_TO_TRANSER_ITENS_ERC721"
            );c_0x5e51bd03(0xdb78d835b1a12635957fe0f4d144e56da96b9cd01bdb3fa598b7a1122dfbcd1f); /* requirePost */ 

        }else { c_0x5e51bd03(0x8c76ce3cc737f141e3b0226fe1646db5e06a9020af03886ebd30ed01e8a352a7); /* branch */ 
}
c_0x5e51bd03(0x27d4a8b64c3be1746edb11cd428d85ed0f181c91cb406f5040511b43b8c889f6); /* line */ 
        c_0x5e51bd03(0x1f10250134302586f42c0218fa5a2728abcf8e87545dc5f8ba12a917d2a501cf); /* statement */ 
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
    ) internal view returns (bool) {c_0x5e51bd03(0x32ebbdb95f3e904cc28b293edff1b2be7dfefd8df951a32ea65be7868ec0c118); /* function */ 

c_0x5e51bd03(0x57534a2e226bab107f1e0f7b7006b031cbba5c12a0254b36d34713cae0aad07f); /* line */ 
        c_0x5e51bd03(0x3cdb3783c1e3c909ba3f981f221a432d919c320631d511bd0c7922e0c0552543); /* requirePre */ 
c_0x5e51bd03(0x999bce3af24298c82d6c3be4ad934a412b206e45c7c6738f8fd018ef92a3fb1d); /* statement */ 
require(
            amount <= IERC20(tokenAddress).balanceOf(from),
            "WEB3BAZAAR_ERROR: ERR_NOT_ENOUGH_FUNDS_ERC20"
        );c_0x5e51bd03(0xb30d226cd79f95bad282e2ff876ff0938dab559b372f7f6c34f18876a0d3342d); /* requirePost */ 

c_0x5e51bd03(0x1cd2b1db6aa52ff4803c7bbfd9f1f10267f36932075aec1b837e65c9e46e0c96); /* line */ 
        c_0x5e51bd03(0xb56ad6c534b1621f5995fa5ee3ab57d2f4bc853fb144a2b912a5c850b32b6c98); /* statement */ 
if (verifyAproval) {c_0x5e51bd03(0x2dd5cf0fbc9d1ec918dbcdad4975e2b9d33d7f0b3eced5594910ab9ec612bbad); /* branch */ 

c_0x5e51bd03(0x9e10a6e0ac5f32ce2f213c480e9ee3217e622198bc2f1d2a39e9bee0d61154dc); /* line */ 
            c_0x5e51bd03(0xba8cb337286ecdaa0a22ba0e1995b363d0ceda12c31d8724c9643be77fc69c5f); /* requirePre */ 
c_0x5e51bd03(0xaae62b458b71d8477136ea92236b667f76f3d8b50656832653556b539d146541); /* statement */ 
require(
                amount <= IERC20(tokenAddress).allowance(from, address(this)),
                "WEB3BAZAR_ERROR: ERR_NOT_ALLOW_SPEND_FUNDS"
            );c_0x5e51bd03(0xb18956bf6356f997725efb5e990f8619911eda0db9116303891e1ec70dd1ae4f); /* requirePost */ 

        }else { c_0x5e51bd03(0xc3c5bf64513c679614ff41c3becfa8942e828d723d0c3b771a1caa5c79af2413); /* branch */ 
}
c_0x5e51bd03(0xb538202522a7f3d4df59ec76061dbf8b7afad2d7a333fef9a48819b006f0a9e4); /* line */ 
        c_0x5e51bd03(0x8f1b23a4f073ad2090272647dff4a649a5f08b744eef5431f36a5fa1575e7807); /* statement */ 
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
    ) internal view returns (bool) {c_0x5e51bd03(0xd006a04be24bdff18175bd7a10f232422cd0dab80d128462d3e7487082e09617); /* function */ 

c_0x5e51bd03(0xa97e83cfc6971d5b8bc21c0c9fe2876267edc76ee6ed39904abe7e94be637793); /* line */ 
        c_0x5e51bd03(0xb3699d85a292e5afd292c6ca243c82ae263aa2c7e7e8f51a08b8d292594147e9); /* requirePre */ 
c_0x5e51bd03(0x1ae485edc06df493400f911195c591f25003900e3ac4ea8fc10794cdd50b043a); /* statement */ 
require(
            tokenId > 0,
            "WEB3BAZAAR_ERROR: STAKE_ERC1155_ID_SHOULD_GREATER_THEN_0"
        );c_0x5e51bd03(0xff073cd67659122b4541c030a192986840096b96e4c0e550a5b4745cbc27b1fb); /* requirePost */ 

c_0x5e51bd03(0xdb64be1816bf700fcbf74910e1d3f7d14394849775e8fe5595836e358aeeb387); /* line */ 
        c_0x5e51bd03(0x5a9b83fed5f20384d26668b0f0a030aff35d7ef1706718295b0880bfa2ebfe49); /* requirePre */ 
c_0x5e51bd03(0x06ac467ba6f1f37de2122dcac8c8855816bbe268db45675efd4638c42d7d3c3a); /* statement */ 
require(
            amount > 0 &&
                amount <= ERC1155(tokenAddress).balanceOf(from, tokenId),
            "WEB3BAZAAR_ERROR: ERR_NOT_ENOUGH_FUNDS_ERC1155"
        );c_0x5e51bd03(0x4cc6153c8d4e12d94bed94a7017be19b19a8d15b530cbaae5a73a64075123573); /* requirePost */ 

c_0x5e51bd03(0xc8222f1802c3a25eaea56fabdf2d745e4f7d2268f9738811508c5957a56cb9f3); /* line */ 
        c_0x5e51bd03(0x972031279bebcb3c35a4cd060790fb7e73369d8328a5882521153310cd2c6cc8); /* statement */ 
if (verifyAproval) {c_0x5e51bd03(0x515ecff5f7b6c45494bb573866cf4d5f71c085113ab2d1ef5779f92a56755379); /* branch */ 

c_0x5e51bd03(0x2c4769bd7191d17e99b76f4f30e0214ff230011c0c44d5901df137d0ed89cd5a); /* line */ 
            c_0x5e51bd03(0x02889dcbf95627a67661ed0047d1f42bc220cb3033f5a0b84aacd350c83803e8); /* requirePre */ 
c_0x5e51bd03(0xa27ce8e62ec207eafb9203ade3bbf3df1f1c68a361ec97ddb9c75a645bf3c00b); /* statement */ 
require(
                ERC1155(tokenAddress).isApprovedForAll(from, address(this)),
                "WEB3BAZAR_ERROR: ERR_NOT_ALLOW_TO_TRANSER_ITENS_ERC1155"
            );c_0x5e51bd03(0x8431a6b54b57fe468f417e9d6e68370c451a4d550f93ca7acb9674721e5657be); /* requirePost */ 

        }else { c_0x5e51bd03(0x556628703634fdb9fcf29296047c076334aeecf9fed27f66c18825fbb5146804); /* branch */ 
}
c_0x5e51bd03(0x5c6739f31541c8e6a7711b16c061afa5878cf66c7c117b293994bd747641c33d); /* line */ 
        c_0x5e51bd03(0xc5972cf290ec49fac0d9977dd86c1a559d5266020a40e1e48a4b03047f39d326); /* statement */ 
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
    ) internal returns (bool) {c_0x5e51bd03(0xf37c26cd1aca9de791e502e6c82a3593631c13bd2cee4315bc8e79c873c6efdd); /* function */ 

c_0x5e51bd03(0x7a3942f3d373393919558ced23b6295f51eff4cf83bca6899c2a38fba89616f5); /* line */ 
        c_0x5e51bd03(0xa6265e1db9d6f49907a652bba7370e0e32cf923b5f6adc5906e4a9abd0f6f5ed); /* statement */ 
verifyERC721(from, tokenAddress, tokenId, true);
c_0x5e51bd03(0xa29690a61b6db7443f246182ae451f5cc7cb4f16f23d971b8f2a83c99a037024); /* line */ 
        c_0x5e51bd03(0x6e95180c7a4876444a00a53808e8fb083271eb0dd5c797ac7c67f1f8a06c5460); /* statement */ 
ERC721(tokenAddress).safeTransferFrom(from, to, tokenId, "");
c_0x5e51bd03(0xbb930db27f14319c3a1ffd061b01504ddeeb68e671c953793144873d30266c26); /* line */ 
        c_0x5e51bd03(0x2260b3771e070b13566ffe6f38d2d6573fde19e232022af42756832a2e4f0ac9); /* statement */ 
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
    ) internal returns (bool) {c_0x5e51bd03(0x2b676aedeff5b5928b4c2a12b880b8b09564cda6eb92c3e2a770b38f7d729e0f); /* function */ 

c_0x5e51bd03(0x811988aac676fef7d532985bbda3dd4e10930c25fe475a25193cd4e9aedca7ac); /* line */ 
        c_0x5e51bd03(0x44acf33a49a39e74506bd384cb40b300d62a3337f464c9ac778749d1ed5cf97e); /* statement */ 
verifyERC1155(from, tokenAddress, amount, tokenId, true);
c_0x5e51bd03(0xc1c62a6585dcfda8562b50ffa1ac64e1872b21f73698088a98a3f6ff36c7f3e3); /* line */ 
        c_0x5e51bd03(0xd2e25701981931663555d5a6db54b8f7858dcc3853a089278bdc42f097afe2bf); /* statement */ 
ERC1155(tokenAddress).safeTransferFrom(
            from,
            to,
            tokenId,
            amount,
            "0x01"
        );
c_0x5e51bd03(0x96708001c8eb8d2a11f3f7efd56bb80332e2291d3cc9eede7ce84e0854d92efd); /* line */ 
        c_0x5e51bd03(0x58180690720957513f1cf6fde65bb42e65f7ad508254c24a42e21154452d7abe); /* statement */ 
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
    ) internal returns (bool) {c_0x5e51bd03(0xa02f588f05826df2b35018c12005caa1dacd56d3fa9dfadcee7399e272d794d5); /* function */ 

c_0x5e51bd03(0xc0732a3c88f41c4b3e1b0e34d7b7d479400d9985d03834997723ae8c36e9b7cd); /* line */ 
        c_0x5e51bd03(0x379c6af9dbfb53ec881460526ccd5666685f6dfea7d891cd0c6c45ef97168563); /* statement */ 
verifyERC20(from, tokenAddress, amount, true);
c_0x5e51bd03(0x4d329116a8da27c4bbc8ee49f1dbf4bfbf85cbb4673b9a361217ae47bdb923b4); /* line */ 
        c_0x5e51bd03(0x63e02216140e03d423094110fd25dfebe7f6df07637afe84045ca730640c0e8a); /* statement */ 
SafeERC20.safeTransferFrom(IERC20(tokenAddress), from, to, amount);
c_0x5e51bd03(0x3e4ca97a5a0ea5c125c690f0777bbf59b47cef4f28d7db44ce6ecf3b5e318bf2); /* line */ 
        c_0x5e51bd03(0x44fb7fbe3609867a4aad0a78060d2634ab04cb319e1f0b716e57ad7baaa0d16b); /* statement */ 
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
    {c_0x5e51bd03(0x52825902e1cc4bb17b422d4012ac6b07f57f04acdf12bff224638b2d5bbe737d); /* function */ 

c_0x5e51bd03(0xa67bd82e6090ec98a14bb0f87c892bc720b32744702324f0db60137c5e880c95); /* line */ 
        c_0x5e51bd03(0xef3af14d1cd9e0f83dd9fdefddb4e04ec625a84167d516dfd880dfe9fee93b4e); /* statement */ 
uint256[] memory userTrades = _openTrades[u];

c_0x5e51bd03(0x2fbf9a0f23857b01520e6234676b7381165b47d6194c8d45f1cb76f8c1e5d7cf); /* line */ 
        c_0x5e51bd03(0xe0ce0038d6446b912c1dd49c49126dac676d7c0c89bc3bf030b4b7e0717b9f37); /* statement */ 
if (_openTrades[u].length == 1) {c_0x5e51bd03(0x880f58817b5ce422925afc1110229ba44939b26ba9b8e674bdd1ca9d0fffd213); /* branch */ 

c_0x5e51bd03(0x02f963bcd9da46afb42a0969a837ac9ca16b76a3de549dc47af35df414b57566); /* line */ 
            c_0x5e51bd03(0xc15c05375d5353cac7b7c70f587e6332b45333a84454c4bf6b8dba22bf889833); /* statement */ 
_openTrades[u][0] = 0;
c_0x5e51bd03(0xc02046616fd540659f8ae954883ca2fceef1c6123e03a468bb7c3a4eefcf83bf); /* line */ 
            c_0x5e51bd03(0x3a31c30c7093ec78b9f7812af7cc2d314a2bb4ce9ff0d2a9e5f6031b2bb92712); /* statement */ 
return true;
        }else { c_0x5e51bd03(0x0f226a81c4305554594483b86a686c9b2f1402357fcedb234e535f47418eb450); /* branch */ 
}
c_0x5e51bd03(0x4e22ad95acdf25cbd0775e743b056990390d001c832846328b480c273a6464d5); /* line */ 
        c_0x5e51bd03(0x44ed2c983324514202e4287a45b22da231f072103859611ef48ca75a6eec43ca); /* statement */ 
for (uint256 i = 0; i < userTrades.length - 1; i++) {
c_0x5e51bd03(0x4cef91ed754041b677f6cde5ef7153016abdeb8736cbec741967e2cd26e4266f); /* line */ 
            c_0x5e51bd03(0x7a87539a7e4e576fd5d379e6a01126aa3c58857d1d37fa53573d5742c4bb7dda); /* statement */ 
if (userTrades[i] == tradeId) {c_0x5e51bd03(0x8228f4579fa5e541affbbbf572f1a47f584f8a93481d9428c0a45e7354e29357); /* branch */ 

c_0x5e51bd03(0x83d14f671b52853604e5ec020f7196796921c660865eef378fc51be37118825a); /* line */ 
                c_0x5e51bd03(0x95b9493a228b6ff9950557f5228e56d593ed6e66cf9cfba9fe47724a733c7c71); /* statement */ 
_openTrades[u][i] = _openTrades[u][userTrades.length - 1];
c_0x5e51bd03(0xa82ef907a6c23075fd8b46b194dbdbd6491662b87fe0b19e783eae5c7e82a36e); /* line */ 
                c_0x5e51bd03(0xedf1872613eaf4113d8e5634be390ecf2a7db42e311d6758d835759be4d2c2b0); /* statement */ 
_openTrades[u].pop();
c_0x5e51bd03(0x227e66ed4b53b796ce1347ea4e7493a0931f7bb31ffaf826dceddf17f58fb81d); /* line */ 
                c_0x5e51bd03(0x73298b36eb611542097abe9e05ccefd11208ae5de89524ee37a41ed1a1426546); /* statement */ 
return true;
            }else { c_0x5e51bd03(0x807dd6544bfd79e6f0f149a8015e79181af364afe47b086fcf5551b9e3ff1d0e); /* branch */ 
}
        }
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
    ) private pure returns (bool) {c_0x5e51bd03(0x0587bd55e138f05e63fcdd769e9f1a1aedd1a1fbc41c1e7c975901258c5689a1); /* function */ 

c_0x5e51bd03(0x9451c0c6b46f7681e704653d62302eb3ea46aca9a7d39cdb7115ce7d5a47587b); /* line */ 
        c_0x5e51bd03(0x633a41181c8b418df5d5481e5deb1444178c389f3bc1f5e92e2fb328a523c1f6); /* requirePre */ 
c_0x5e51bd03(0xcd465e09cb27dffa958eb413ea3101df65dddc57a76b37dc6a8fb562ef713916); /* statement */ 
require(
            tokenAddress != address(0),
            "WEB3BAZAAR_ERROR: CONTRACT_TOKEN_ADDRESS_IS_ZERO"
        );c_0x5e51bd03(0x265fcfe6dd9a3b2b7eb46a4a37d521e7b31936d2668f69a6247869062fd77a7c); /* requirePost */ 

c_0x5e51bd03(0x05432fdf1d5ab1443c06470b29bba65294223222cd0cd59f6e1da8a35fd31e94); /* line */ 
        c_0x5e51bd03(0x44257a2c1c5ae8e792d8f358763c2015f464f7b9a85c62b113d1cf9f6b71997f); /* requirePre */ 
c_0x5e51bd03(0x116f2e33c9ece36e02ebb61671214bca9c3c2f38fdc9aee954507fd73673dbe6); /* statement */ 
require(
            tokenType > uint8(TradeType.NON) &&
                tokenType <= uint8(TradeType.ERC721),
            "WEB3BAZAR_ERROR: NOT_VALID_TRADE_TYPE"
        );c_0x5e51bd03(0xe598e8a87fbfcc7e13e7b22cdf720df6ce2fbc9491c546d322768a1384145040); /* requirePost */ 

c_0x5e51bd03(0xf68fc2e13ef2b05a3d3a0a05e8c1d9c9d4a7d68b5ca46dfb240c08cc921ba757); /* line */ 
        c_0x5e51bd03(0x32dcc36ade98e28fbdb54b0a48cb298c8459445e5b1851231d45418e7e9036e1); /* requirePre */ 
c_0x5e51bd03(0xc95db4cba59c0ecd5c2c3ef9d3eba05286f671754ae27818f557882a7d7e2172); /* statement */ 
require(tokenId > 0, "WEB3BAZAR_ERROR: TOKENID_MUST_POSITIVE");c_0x5e51bd03(0x43719c5b65567bd93ca5b67bf9319ea9928bc59efbae23600cd0eaeeba833cf6); /* requirePost */ 

c_0x5e51bd03(0xac144a7bf3182ed8362a978d7813d3953e22e107431c37c66292aaded0d70e94); /* line */ 
        c_0x5e51bd03(0xcb70b045d0ad8e64d1aa76186c21850dcd8e77424896385b228b0940e8ed25a5); /* requirePre */ 
c_0x5e51bd03(0x85e8543e17bb36e259aa8325b87893224100247a6bec9d496cb0d9c8d14c0b86); /* statement */ 
require(amount > 0, "WEB3BAZAR_ERROR: AMOUNT_MUST_POSITIVE");c_0x5e51bd03(0x6ab1be9cb1c51a80bfc1e8f0f49ac7526c58987546be726be32981e993426231); /* requirePost */ 

c_0x5e51bd03(0x4d506cb20d027954d6a6087d5b1630c4cf38f8b37e20c8809e8ee60964ca8885); /* line */ 
        c_0x5e51bd03(0x55c3e294b24a7e340951d45646c3f3147292e1abbd1f255f6be50c621004ce94); /* statement */ 
return true;
    }
}
