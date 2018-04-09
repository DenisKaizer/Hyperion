pragma solidity ^0.4.15;

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract Crowdsale {
  function claimFreezedTokens(address claimer) public {}
  address public foundersWallet;
  uint256 public endTime;
}

contract Presale {
  function claimFreezedTokens(address claimer) public {}
}



contract unFreeze is Ownable {

  using SafeMath for uint256;

  address crowdsale;
  address preSale;
  address foundersWallet;
  ERC20 token;
  uint256 claimableTokens;
  uint256 claimedTokens;


  function addCrowdsale (address _crowdsale) onlyOwner {
    crowdsale = _crowdsale;
    foundersWallet = Crowdsale(crowdsale).foundersWallet();
  }

  function addPreSale (address _preSale) onlyOwner {
    preSale = _preSale;
  }

  function addToken (address _token) onlyOwner {
    token = ERC20(_token);
  }


  function unFreeze() {
    Crowdsale(crowdsale).claimFreezedTokens(msg.sender);
    Presale(preSale).claimFreezedTokens(msg.sender);
  }

  function claimSucces() {
    require(msg.sender == foundersWallet);
    uint256 endTime = Crowdsale(crowdsale).endTime();
    uint256 periodsPassed = now.sub(endTime).div(31536000);
    if (periodsPassed > 5) {
      periodsPassed = 5;
    }
    uint256 availableTokens = (claimableTokens.mul(periodsPassed)).sub(claimedTokens);
    if (availableTokens >= token.balanceOf(this)) {
      availableTokens = token.balanceOf(this);
    }
    claimedTokens = claimedTokens.add(availableTokens);
    token.transfer(foundersWallet, availableTokens);
  }
}
