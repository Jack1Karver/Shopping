pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import 'ShoppingDebot.sol';

contract D_FillingShoppingList is ShoppingDebot{

    
    function _menu() public override{
        string sep = '----------------------------------------';
        Menu.select(
            format(
                 "You have {} / {} / {} (unpaid / paid / total )",
                    p_stat.unpaid,
                    p_stat.paid,
                    p_stat.total
            ),
            sep,
            [
                MenuItem("Add purchase","",tvm.functionId(createPurchase)),
                MenuItem("Show shopping list","",tvm.functionId(showPurchases)),
                MenuItem("Delete purchase","",tvm.functionId(deletePurchase))
            ]
        );
    }
    
    function createPurchase(uint32 index) public{
        index = index;
        Terminal.input(tvm.functionId(createPurchase_), "Enter product name:", false);
    }

    function createPurchase_(string value) public {
        nameOfProduct = value;
        Terminal.input(tvm.functionId(createPurchase__), "Enter amount:", false);
    }
        
    function createPurchase__(string value) public {
        (uint256 num,) = stoi(value);
        amountOfProducts = uint32(num);
        optional(uint256) pubkey = 0;
        IShopList(p_address).createPurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(nameOfProduct, amountOfProducts);
    }

    function showPurchases(uint32 index) public view {
        index = index;
        optional(uint256) none;
        IShopList(p_address).getPurchases{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: tvm.functionId(onSuccess),
            callbackId: tvm.functionId(showPurchases_),
            onErrorId: 0
        }();
    }

    function showPurchases_( Purchase[] purchases ) public {
        uint32 i;
        if (purchases.length > 0 ) {
            Terminal.print(0, "Your shopping list:");
            for (i = 0; i < purchases.length; i++) {
                Purchase purchase = purchases[i];
                string completed;
                if (purchase.bought) {
                    completed = '✓';
                } else {
                    completed = ' ';
                }
                Terminal.print(0, format("{} {}  \"{}\" Quantity: {} Price: {}  at {}", purchase.id, completed, purchase.title, purchase.quantity, purchase.price, purchase.createdAt));
            }
        } else {
            Terminal.print(0, "Your shopping list is empty");
        }
        _menu();
    }

    function deletePurchase(uint32 index) public {
        tvm.functionId(showPurchases); 
        index = index;
        if (p_stat.paid + p_stat.unpaid > 0) {
            Terminal.input(tvm.functionId(deletePurchase_), "Enter product number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no products to delete");
            _menu();
        }
    }

    function deletePurchase_(string value) public view {
        (uint256 num,) = stoi(value);
        optional(uint256) pubkey = 0;
        IShopList(p_address).deletePurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(uint32(num));
    }
} 