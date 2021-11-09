pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "ContractResources.sol";
import "ShoppingDebot.sol";

contract ListEntry is ShoppingDebot{    
    
    uint p_price;
    function _menu() public override{
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{}/{} (unpaid/paid/total) purchases",
                    p_stat.unpaid,
                    p_stat.paid,
                    p_stat.total
            ),
            sep,
            [
                MenuItem("Buy ","",tvm.functionId(buy)),
                MenuItem("Show purchases list","",tvm.functionId(showPurchases)),
                MenuItem("Delete purchase","",tvm.functionId(deletePurchase))
            ]
        );
    }
    function buy() public {     
        if (p_stat.unpaid > 0) {
            Terminal.input(tvm.functionId(buy_), "Enter purchase number:", false);
        } 
        else if(p_stat.total > 0){
            Terminal.print(0, "Congrats! You've bought all purchases! We have nothing else to buy.");
            _menu();
        }
        else{
            Terminal.print(0, "We have nothing to buy");
            
        }
    }    
    function buy_(string value) public {
        (uint num,) = stoi(value);
        p_purchaseId = uint32(num);
        Terminal.input(tvm.functionId(setPrice), "Enter the quantity", false);
        ConfirmInput.get(tvm.functionId(buy__),"Are you sure you bought this?");
    }
    function setPrice(string price) public{
        (uint num,) = stoi(price);
        p_price = num;
    }

    function buy__(string value) public {
        
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
            }(p_purchaseId, p_price);
    }

   
    function showPurchases() public view {        
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

        function showPurchases_(Purchase[] list ) public {
        if (list.length > 0 ) {
            Terminal.print(0, "Your tasks list:");
            for (uint i = 0; i < list.length; i++) {
                Purchase purchase = list[i];
                string completed;
                if (purchase.bought) {
                    completed = '✓';
                } else {
                    completed = 'X';
                }
                Terminal.print(0, format("{} {}  {}  {} {} {} ", purchase.id, completed, purchase.title, purchase.quantity,purchase.price,purchase.time));
            }
        } else {
            Terminal.print(0, "Your tasks list is empty");
        }
        _menu();
    }
    function deletePurchase() public {
        if (p_stat.total > 0) {
            Terminal.input(tvm.functionId(deletePurchase_), "Enter purchase number:", false);
        } else {
            Terminal.print(0, "Sorry, you have no purchase");
            _menu();
        }
    }
    function deletePurchase_(string value) public view{
        (uint num,) = stoi(value);
        optional(uint) pubkey = 0;
        IShopList(p_address).deletePurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(num);
    }
}
    

