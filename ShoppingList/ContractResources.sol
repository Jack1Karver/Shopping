
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

struct Purchase{
    uint id;
    string title;
    uint quantity;
    uint64 time;
    bool bought;
    uint price;    
}

struct PurchaseTotal{
    uint paid;
    uint unpaid;
    uint total;
}

interface IShopList {   
    function buy(uint id, uint price) external;
    function deletePurchase(uint id) external;
    function getPurchases() external returns (Purchase[] list);
    function getTotal() external returns (PurchaseTotal totalStat);
    function createTitle(string title) external;
    function createQuantity(uint quantity) external;
}

interface Transactable{
    function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload  ) external;
}

abstract contract HasConstructorWithPubkey {
    constructor(uint256 pubkey) public {}
}