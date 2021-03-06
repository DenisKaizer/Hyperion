pragma solidity ^0.4.18;

import "./HyperionWattToken.sol";
import "./WhiteList.sol";

contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private rentrancy_lock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!rentrancy_lock);
    rentrancy_lock = true;
    _;
    rentrancy_lock = false;
  }
}

contract Presale is Ownable, ReentrancyGuard {
  using SafeMath for uint256;

  // The token being sold
  HyperionWattToken public token;
  WhiteList public whiteList;
  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public rate; // tokens for one cent

  uint256 public priceUSD; // wei in one USD cent
  uint256 public minimumInvest = 600; // USD cent
  

  uint256 public hardCap;

  address oracle; //
  mapping (address => bool) public managers;

  // investors => amount of money
  mapping(address => uint) public balances;
  mapping(address => uint) public balancesInCent;
  mapping(address=>uint) public claimedTokens;
  mapping(address=>uint) public claimableTokens;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

//1520105792,1,"0x3dd90d5eb224c4637f885b7476eccba6b3aa45c5","0xf65953c15af0324d7c0ade9719728309aef87942",11621461119820
  function Presale(
  uint256 _startTime,
  uint256 _period,
  address _wallet,
  address _token,
  uint256 _priceUSD,
  address _whitelist) public
  {
    require(_period != 0);
    require(_priceUSD != 0);
    require(_wallet != address(0));
    require(_token != address(0));
    require(_whitelist != address(0));

    startTime = _startTime;
    endTime = startTime + _period * 1 days;
    priceUSD = _priceUSD;
    rate = 16666670000000000; // 0.01666667 * 1 ether
    wallet = _wallet;
    token = HyperionWattToken(_token);
    whiteList = WhiteList(_whitelist);
    hardCap = 100000000 * 1 ether; // inTokens
    
  }

  // @return true if the transaction can buy tokens
  modifier saleIsOn() {
    bool withinPeriod = now >= startTime && now <= endTime;
    require(withinPeriod);
    _;
  }

  modifier isUnderHardCap() {
    require(token.totalSupply() <= hardCap );
    _;
  }

  modifier onlyOracle(){
    require(msg.sender == oracle);
    _;
  }

  modifier onlyOwnerOrManager(){
    require(managers[msg.sender] == true || msg.sender == owner);
    _;
  }

  modifier CanClaimNow (){
    require(now>endTime + 2592000);
    _;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }

  // Override this method to have a way to add business logic to your crowdsale when buying
  function getTokenAmount(uint256 centValue) internal view returns(uint256) {
    return centValue.mul(rate);
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds(uint256 value) internal {
    wallet.transfer(value);
  }

  function finishPreSale() public onlyOwner {
    token.transferOwnership(owner);
   
  }

  // set the address from which you can change the rate
  function setOracle(address _oracle) public  onlyOwner {
    require(_oracle != address(0));
    oracle = _oracle;
  }

  // set manager's address
  function setManager(address _manager) public  onlyOwner {
    require(_manager != address(0));
    managers[_manager] = true;
  }

  function changePriceUSD(uint256 _priceUSD) public  onlyOracle {
    require(_priceUSD != 0);
    priceUSD = _priceUSD;
  }

  function claimFreezedTokens(address claimer) public nonReentrant CanClaimNow {
    uint256 periodsPassed = now.sub(endTime).div(2592000);
    if (periodsPassed > 2) {
      periodsPassed = 2;
    }
    uint256 availableTokens = (claimableTokens[msg.sender].mul(periodsPassed)).sub(claimedTokens[claimer]);
    if (availableTokens + claimedTokens[claimer] > claimableTokens[claimer].mul(2)){
      availableTokens = claimableTokens[claimer].mul(2) - claimedTokens[claimer];
    }

    claimedTokens[claimer] = claimedTokens[claimer].add(availableTokens);
    token.transfer(claimer,availableTokens);
  }

  // manual selling tokens for fiat
  function manualTransfer(address _to, uint _valueUSD) public saleIsOn isUnderHardCap onlyOwnerOrManager {
    uint256 centValue = _valueUSD;
    uint256 tokens = getTokenAmount(centValue);
   
    uint256 tokensToSend = tokens.div(2); // 50% right now
    token.mint(_to, tokensToSend); // mint 50% to beneficiary 
    claimableTokens[_to] += tokens.div(4); // save 25% as "claimableTokens"
    token.mint(this, tokens.div(2));
    balancesInCent[_to] = balancesInCent[_to].add(centValue);
    
  }

  // low level token purchase function
  function buyTokens(address beneficiary) saleIsOn isUnderHardCap  nonReentrant public payable {
    require(beneficiary != address(0) && msg.value.div(priceUSD) >= minimumInvest);
    require(whiteList.isInWhiteList(msg.sender));
    uint256 weiAmount = msg.value;
    uint256 centValue = weiAmount.div(priceUSD);
    uint256 tokens = getTokenAmount(centValue);
    
    uint256 tokensToSend = tokens.div(2); // 50% right now
    token.mint(beneficiary, tokensToSend); // mint 50% to beneficiary
    claimableTokens[msg.sender] += tokens.div(4); // save 25% as "claimableTokens"
    token.mint(this, tokens.div(2)); // mint 50% for "this", it should be claimed after 2 month's
    balances[msg.sender] = balances[msg.sender].add(weiAmount);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    forwardFunds(weiAmount);
  }

  function () external payable {
    buyTokens(msg.sender);
  }
}









