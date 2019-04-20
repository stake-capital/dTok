pragma solidity 0.4.25;

import "openzeppelin-solidity/contracts/access/Roles.sol";
import "ERC20Vendable.sol";

contract AdminRole {
  using Roles for Roles.Role;

  event AdminAdded(address indexed account);
  event AdminRemoved(address indexed account);

  Roles.Role private admins;
  address public superAdmin;

  constructor() public {
    _addAdmin(msg.sender);
    superAdmin = msg.sender;
  }

  modifier onlyAdmin() {
    require(isAdmin(msg.sender));
    _;
  }

  modifier onlySuperAdmin() {
    require(isSuperAdmin(msg.sender));
    _;
  }

  function isAdmin(address account) public view returns (bool) {
    return admins.has(account);
  }

  function isSuperAdmin(address account) public view returns (bool) {
    return account == superAdmin;
  }

  function addAdmin(address account) public onlySuperAdmin {
    _addAdmin(account);
  }

  function removeAdmin(address account) public onlySuperAdmin {
    _removeAdmin(account);
  }

  function renounceAdmin() public {
    _removeAdmin(msg.sender);
  }

  function _addAdmin(address account) internal {
    admins.add(account);
    emit AdminAdded(account);
  }

  function _removeAdmin(address account) internal {
    admins.remove(account);
    emit AdminRemoved(account);
  }
}

contract WhitelistedRole is AdminRole {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender));
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyAdmin {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyAdmin {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(msg.sender);
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}



contract BroadcastingMachine is AdminRole, WhitelistedRole {
  using SafeMath for uint256;

  ERC20Vendable public tokenContract;
  mapping (address => uint256) public allowance;

  event Deposit(address indexed depositor, uint amount);
  event Withdraw(address indexed withdrawer, uint amount);

  constructor(address _tokenContract) public {
    tokenContract = ERC20Vendable(_tokenContract);
  }

  //Fallback. Just send currency here to deposit
  function () external payable {
    deposit();
  }

  /**
  * @dev Deposit currency in order to buy tokens from the ERC20Contract
  * Will buy tokens at a 1-to-1 ratio. User will also be given an allowance to withdraw the same amount.
  */
  function deposit() public payable {
    _addAllowance(msg.sender, msg.value);

    tokenContract.mint(msg.sender, msg.value);
    emit Deposit(msg.sender, msg.value);
  }

  /**
  * @dev Admin hook to increment an account's withdraw allowance.
  * Could be useful if they don't want to give the user unlimited withdraw by whitelisting them
  * @param account The address to receive the increased allowance.
  * @param amount The amount to increase the allowance
  */
  function addAllowance(address account, uint256 amount) public onlyAdmin {
    _addAllowance(account, amount);
  }

  function _addAllowance(address account, uint256 amount) private {
    allowance[account] = allowance[account].add(amount);
  }

  function withdraw(uint256 amount) public {
    if(isWhitelisted(msg.sender)) {
      _withdraw(amount);
    } else {
      require(amount <= allowance[msg.sender]);
      allowance[msg.sender] = allowance[msg.sender].sub(amount);
      _withdraw(amount);
    }
  }

  function _withdraw(uint256 amount) private {
    tokenContract.burn(msg.sender, amount);
    msg.sender.transfer(amount);
    emit Withdraw(msg.sender, amount);
  }

  function adminMint(address to, uint256 amount) public onlyAdmin {
    tokenContract.mint(to, amount);
  }

  function sweep(uint256 amount) public onlySuperAdmin {
      msg.sender.transfer(amount);
  }

//*****************  Broadcast/User related code *******************//

  mapping (address => Broadcast) public broadcasts;

  mapping (address => User) public users;

  event UpdateBroadcast(address indexed broadcaster, uint256 streamID, bool isLive, uint256 blockEnd);
  event AddUser(address indexed user, uint256 userID, uint256 payedTill);

  struct Broadcast {
    uint256 streamID;
    address paymentAddress;
    bool isLive;  // indicate if the stream is live
    uint256 blockEnd; //block on which the strem is ending
  }

  struct User {
    uint256 userID;
    uint256 payedTill; // block number till which user payed 
                       // TODO: add formula to calculate blocknumber
  }

function addBroadcast(uint256 _streamID, address _paymentAddress, uint256 _blockEnd) public {
  // require(!broadcasts[_paymentAddress].exists, "BroadcastMachine::addBroadcast This address already is a broadcaster.");

    broadcasts[_paymentAddress] = Broadcast({
      streamID: _streamID,
      paymentAddress: _paymentAddress,
      isLive: true,
      blockEnd: _blockEnd
    });

  _emitUpdateBroadcast(_paymentAddress);
  }


  function addUser(uint256 _userID, uint256 _payedTill) public {
    // require(vendors[msg.sender].isAllowed, "VendingMachine::addProduct - vendor is not allowed by admin");
    users[msg.sender] = User({
      userID: _userID,
      payedTill: _payedTill
    });

    emit AddUser(msg.sender, _userID, _payedTill);
  }

  function statusBroadcast(bool _isLive) public {
    //Existing vendor check happens in _updateVendor. No need to do it here
    _updateBroadcast(
      msg.sender, // I would change it to _paymentAddress as well
      broadcasts[msg.sender].streamID,
      _isLive,
      broadcasts[msg.sender].blockEnd
    );
  }
                                                                                                        
  function updateBroadcast(address _paymentAddress, uint256 _streamID, bool _isLive, uint256 _blockEnd) public {
    _updateBroadcast(_paymentAddress, _streamID, _isLive, _blockEnd);
  }

  function _updateBroadcast(address _paymentAddress, uint256 _streamID, bool _isLive, uint256 _blockEnd) private {
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
  }}
