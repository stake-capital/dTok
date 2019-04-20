pragma solidity 0.4.25;

//import "openzeppelin-solidity/contracts/access/Roles.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract BroadcastingMachine is Ownable {

//*****************  Broadcast/User related code *******************//

  mapping (address => Broadcast) public broadcasts;
 
  event UpdateBroadcast(address indexed broadcaster, string streamID, bool isLive, uint256 blockEnd);
  event UpdateUser(address indexed user, uint256 userID, uint256 payedTill, bool canWatch);

  struct Broadcast {
    string streamID;
    address paymentAddress;
    bool isLive;  // indicate if the stream is live
    uint256 blockEnd; //block on which the strem is ending
  }

function addBroadcast(string _streamID, address _paymentAddress, uint256 _blockEnd) public {
//  require(!broadcasts[_paymentAddress].exists, "BroadcastMachine::addBroadcast This address already is a broadcaster.");
  
    broadcasts[_paymentAddress] = Broadcast({
      streamID: _streamID,
      paymentAddress: _paymentAddress,
      isLive: true,
      blockEnd: _blockEnd
    });

  _emitUpdateBroadcast(_paymentAddress);
  }
  function statusBroadcast(bool _isLive) public {
    _updateBroadcast(
      msg.sender, // I would change it to _paymentAddress as well
      broadcasts[msg.sender].streamID,
      _isLive,
      broadcasts[msg.sender].blockEnd
    );
  }
                                                                                                        
  function updateBroadcast(address _paymentAddress, string _streamID, bool _isLive, uint256 _blockEnd) public {
    _updateBroadcast(_paymentAddress, _streamID, _isLive, _blockEnd);
  }

  function _updateBroadcast(address _paymentAddress, string _streamID, bool _isLive, uint256 _blockEnd) private {
//    require(broadcasts[_paymentAddress].exists, "BroadcastMachine::_updateBroadcast Cannot update a non-existent broadcast");

    broadcasts[_paymentAddress].streamID = _streamID;
    broadcasts[_paymentAddress].isLive = _isLive;
    broadcasts[_paymentAddress].blockEnd = _blockEnd;

    _emitUpdateBroadcast(_paymentAddress);
  }

  function _emitUpdateBroadcast(address _paymentAddress) private {
    emit UpdateBroadcast(
      _paymentAddress,
      broadcasts[_paymentAddress].streamID,
      broadcasts[_paymentAddress].isLive,
      broadcasts[_paymentAddress].blockEnd
    );
  }


      mapping (address => uint256) TimeBalance;

      event BuyTime(address sender, uint256 price, uint256 fullPrice);

      function buyTime() public payable returns (bool){
        uint64 price = 200000000000000000;
        require(msg.value == price,
        "Please send 20 xDai cents");

        if (TimeBalance[msg.sender] == 0){
            TimeBalance[msg.sender] = block.number + 46; // ADD: if statement in the future
        } else {
             TimeBalance[msg.sender] += (block.number+46); // ADD: if statement in the future
        }

        emit BuyTime(msg.sender,price,TimeBalance[msg.sender]);
        return true;
}

    function withdraw(address _paymentAddress, uint256 _amount) public onlyOwner {
      require(broadcasts[_paymentAddress].blockEnd != 0,
              "Should be existing broadcaster");
      _paymentAddress.transfer(_amount);
                      
    } 

    function getBalance(address _userAddress) public view returns(uint256) {
        return TimeBalance[_userAddress];
    } 

}