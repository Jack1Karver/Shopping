pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import 'ShoppingDebot.sol';

contract D_Shopping is ShoppingDebot{
    
    
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
                MenuItem("Show shopping list","",tvm.functionId(showPurchases)),
                MenuItem("Delete purchase","",tvm.functionId(deletePurchase)),
                MenuItem("Buy","",tvm.functionId(buy))
            ]
        );
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
            expire: 0,
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
                Terminal.print(0, format("{} {}  \"{}\" Quantity: {}, Price: {}  at {}", purchase.id, completed, purchase.title,purchase.quantity,purchase.price, purchase.createdAt));
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
            Terminal.input(tvm.functionId(deletePurchase_), "Enter purchase number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no purchases to delete");
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

    function buy(uint32 index) public {
        index = index;
        if (p_stat.unpaid > 0) {
            Terminal.input(tvm.functionId(buy_), "Enter purchase number:", false);
        } else {
            Terminal.print(0, "Sorry, you don't have any scheduled purchases");
            _menu();
        }
    }

    function buy_(string value) public {
        (uint256 num,) = stoi(value);
        p_purchaseId = uint32(num);
        Terminal.input(tvm.functionId(buy__), "Enter the purchase price:", false);

    }
    function buy__(string value) public {
        (uint256 num,) = stoi(value);
        p_purchasePrice = uint32(num);
        optional(uint256) pubkey = 0;
        IShopList(p_address).buy{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(p_purchaseId, p_purchasePrice);
    }  
} 