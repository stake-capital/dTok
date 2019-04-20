pragma solidity 0.4.25;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract BroadcastPayable is Ownable{
  		address public broadcastMachine;

  		mapping (address => uint256) emojiBalance;

  		modifier onlyBroadcastMachine() {
    		require(msg.sender == broadcastMachine);
    	_;
  		}

  function buyTime() public returns (bool){
    uint16 price = 200000000000000000;
    // uint256 fullPrice = uint256(price)*2*COSTMULTIPLIER;

    transfer(address(this), price);
    //require(coinInventory[index]>=1,"BroadcastPayable::buyTime");
    //coinInventory[index] = coinInventory[index]--;

    TimeBalance[msg.sender]+=46;

    emit BuyTime(msg.sender,price,TimeBalance[msg.sender]);
    return true;
  }
  event BuyTime(address sender, uint256 price, uint256 fullPrice);
 		


}