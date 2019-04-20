pragma solidity 0.4.25;

//import "openzeppelin-solidity/contracts/access/Roles.sol";
// import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract BroadcastingMachine {
//  using SafeMath for uint256;

//  ERC20Vendable public tokenContract;
//  mapping (address => uint256) public allowance;

  // event Deposit(address indexed depositor, uint amount);
  // event Withdraw(address indexed withdrawer, uint amount);

  // constructor(address _tokenContract) public {
  //   tokenContract = ERC20Vendable(_tokenContract);
  // }

  //Fallback. Just send currency here to deposit
  // function () external payable {
  //   deposit();
  // }

  
//*****************  Broadcast/User related code *******************//

  mapping (address => Broadcast) public broadcasts;
 
 //  mapping (address => User) public users;

  event UpdateBroadcast(address indexed broadcaster, string streamID, bool isLive, uint256 blockEnd);
  event UpdateUser(address indexed user, uint256 userID, uint256 payedTill, bool canWatch);



  struct Broadcast {
    string streamID;
    address paymentAddress;
    bool isLive;  // indicate if the stream is live
    uint256 blockEnd; //block on which the strem is ending
  }

  // struct User {
  //   uint256 userID;
  //   uint256 payedTill; // block number till which user payed 
  //                      // TODO: add formula to calculate blocknumber
  //   bool canWatch;
  // }

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


//   function addUser(uint256 _userID, uint256 _payedTill) public {
// //    require(vendors[msg.sender].isAllowed, "VendingMachine::addProduct - vendor is not allowed by admin");
//     users[msg.sender] = User({
//       userID: _userID,
//       payedTill: _payedTill,
//       canWatch: true // they
//     });

  //   emit UpdateUser(msg.sender, _userID, _payedTill, true);
  // }

//   function cannotWatch(address _user) public {
//     users[_user] = User({
//       userID: users[_user].userID,
//       payedTill: users[_user].payedTill,
//       canWatch: false
//     });      
//     emit UpdateUser(_user, users[_user].userID, users[_user].payedTill, false);
//   }

  function statusBroadcast(bool _isLive) public {
    //Existing vendor check happens in _updateVendor. No need to do it here
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
//      msg.sender
    );
  }

//      address public broadcastMachine;
      // modifier onlyBroadcastMachine() {
      //   require(msg.sender == broadcastMachine);
      // _;
      // }

      mapping (address => uint256) TimeBalance;

      event BuyTime(address sender, uint256 price, uint256 fullPrice);

      function buyTime() public payable returns (bool){
        uint64 price = 200000000000000000;
        require(msg.value == price,
        "Please send 20 xDai cents");

        if (TimeBalance[msg.sender] == 0){
            TimeBalance[msg.sender] = 46; // ADD: if statement in the future
        } else {
             TimeBalance[msg.sender] += 46; // ADD: if statement in the future
        }

        emit BuyTime(msg.sender,price,TimeBalance[msg.sender]);
        return true;

}
}