
pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "ContractResources.sol";

contract Shopping {
    string _title; 
    uint _quantity;
    uint p_ownerPubkey;
    uint count = 1; 
    mapping(uint => Purchase) p_list;

    constructor(uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        p_ownerPubkey = pubkey;
    }

    function createTitle(string title) public onlyOwner{
        tvm.accept();
        _title = title;
    }

    function createQuantity(uint quantity) public onlyOwner{
        tvm.accept();
        _quantity = quantity;
        addPurchase();
    }

    function addPurchase() public onlyOwner {
        tvm.accept();        
        p_list[count] = Purchase(count, _title, _quantity, now, false, 0);        
    }

    function buy(uint id, uint price) public onlyOwner{
        optional(Purchase) purchase = p_list.fetch(id);
        require((purchase.hasValue()),102);
        tvm.accept();
        Purchase _purchase = purchase.get();
        _purchase.bought = true;
        _purchase.price = price;
        p_list[id] = _purchase;
    }

    function deletePurchase(uint id) public onlyOwner {
        require(p_list.exists(id), 102);
        tvm.accept();
        delete p_list[id];
    }

    function getPurchases() public view returns (Purchase[] list) {
        string title; 
        uint quantity;
        uint64 time;   
        bool bought;
        uint price; 

        for((uint id, Purchase purchase) : p_list) {
            title = purchase.title;            
            bought = purchase.bought;
            quantity = purchase.quantity;
            time = purchase.time;
            price = purchase.time;
            list.push(Purchase(id, title, quantity,time,bought,price));
       }
    }

    function getTotal() public view returns (PurchaseTotal totalStat) {
        uint paidCount = 0;
        uint unpaidCount = 0;
        uint totalPrice = 0;

        for((, Purchase purchase) : p_list) {
            if  (purchase.bought) {
                paidCount++;
            } else {
                unpaidCount++;
            }
            totalPrice+=purchase.price;
        }
        totalStat = PurchaseTotal( paidCount, unpaidCount, totalPrice);
    }


    modifier onlyOwner() {
        require(msg.pubkey() == p_ownerPubkey, 101);
        _;
    }

}
