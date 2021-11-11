pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "ContractResources.sol";

contract ShoppingList is IShopList{

    modifier onlyOwner() {
        require(msg.pubkey() == p_ownerPubkey, 101);
        _;
    }

    uint32 count=1;
    mapping(uint32 => Purchase) p_purchase;
    uint256 p_ownerPubkey;

    constructor( uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        p_ownerPubkey = pubkey;
    }

    function createPurchase(string name, uint32 quantity) public onlyOwner override {
        tvm.accept();
        count++;
        p_purchase[count] = Purchase(count, name, quantity, now, false, 0);
    }

    function buy(uint32 id, uint32 price) public onlyOwner override{
        optional(Purchase) purchase = p_purchase.fetch(id);
        require(purchase.hasValue(), 102);
        tvm.accept();
        Purchase thisPurchase = purchase.get();
        thisPurchase.bought = true;
        thisPurchase.price = price;
        p_purchase[id] = thisPurchase;
    }

    function deletePurchase(uint32 id) public onlyOwner override{
        require(p_purchase.exists(id), 102);
        tvm.accept();
        delete p_purchase[id];
    }

    function getPurchases() public override returns (Purchase[] purchases) {
        string title;
        uint32 quantity;
        uint32 price;
        uint64 createdAt;
        bool bought;
        for((uint32 id, Purchase purchase) : p_purchase) {
            title = purchase.title;
            quantity = purchase.quantity;
            createdAt = purchase.createdAt;
            bought = purchase.bought;
            price = purchase.price;
            purchases.push(Purchase(id, title, quantity, createdAt, bought, price));
       }
    }

    function getTotal() public override returns (PurchaseTotal totalStat) {
        uint32 paid;
        uint32 unpaid;
        uint32 totalPrice;
        for((, Purchase purchase) : p_purchase) {
            if  (purchase.bought) {
                paid += purchase.quantity;
            } else {
                unpaid += purchase.quantity;
            }
            totalPrice += purchase.price * purchase.quantity;
        }
        totalStat = PurchaseTotal(paid, unpaid, totalPrice);
    }
}