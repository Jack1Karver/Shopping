pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

struct Purchase{
    uint32 id;
    string title;
    uint32 quantity;
    uint64 createdAt;
    bool bought;  
    uint32 price;  
}

struct PurchaseTotal {
    uint32 paid;
    uint32 unpaid;
    uint32 total;
}

interface IShopList {
    function createPurchase(string title, uint32 count) external;
    function buy(uint32 id, uint32 price) external;
    function deletePurchase(uint32 id) external;
    function getPurchases() external returns (Purchase[] purchases);
    function getTotal() external returns (PurchaseTotal totalStat);
}

interface Transactable {
    function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload) external;
}

abstract contract HasConstructorWithPubkey {
   constructor(uint256 pubkey) public {}
}
