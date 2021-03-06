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

contract Crowdsale is Ownable, ReentrancyGuard {
  using SafeMath for uint256;

  // The token being sold
  HyperionWattToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;
  address public foundersWallet;
  WhiteList public whiteList;


  // how many token units a buyer gets per wei
  uint256 public priceUSD; // wei in one cent USD

  uint256 public centRaised;

  uint256 public hardCap;
  uint256 public softCap;

  address oracle; //
  address manager;

  // investors => amount of money
  mapping(address => uint) public balances;
  mapping(address => uint) public balancesInCent;
  mapping(address=>uint) public claimedTokens;
  mapping(address=>uint) public claimableTokens;
  //mapping (uint256=>uint256) public rates;

  uint256 public initialRate;
  uint256 public finalRate;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(
  uint256 _startTime,
  uint256 _period,
  address _wallet,
  address _foundersWallet,
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
    //rate =  16666670000000000; // 0.01666667 * 1 ether
    wallet = _wallet;
    foundersWallet = _foundersWallet;
    token = HyperionWattToken(_token);
    hardCap = 100000000 * 1 ether; // inTokens
    softCap =  500000000; //in Cents
    whiteList = WhiteList(_whitelist);
    initialRate = 15625000000000000;
    finalRate = 11904760000000000;


    /**
    rates[startTime + 1 days] = 15625000000000000;
    rates[startTime + 2 days] = 15625000000000000;
    rates[startTime + 3 days] = 14492750000000000;
    rates[startTime + 4 days] = 14492750000000000;
    rates[startTime + 5 days] = 13513510000000000;
    rates[startTime + 6 days] = 13513510000000000;
    rates[startTime + 7 days] = 12658230000000000;
    rates[startTime + 8 days] = 12658230000000000;
    rates[startTime + 9 days] = 11904760000000000;
    */
  }

  // @return true if the transaction can buy tokens
  modifier saleIsOn() {
    bool withinPeriod = now >= startTime && now <= endTime;
    require(withinPeriod);
    _;
  }


  modifier isUnderHardCap() {
    require(token.totalSupply() <= hardCap);
    _;
  }

  modifier onlyOracle(){
    require(msg.sender == oracle);
    _;
  }

  modifier onlyOwnerOrManager(){
    require(msg.sender == manager || msg.sender == owner);
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

 modifier refundAllowed()  {
    require(centRaised < softCap && now > endTime);
    _;
  }

  function refund() public refundAllowed nonReentrant {
    uint valueToReturn = balances[msg.sender];
    balances[msg.sender] = 0;
    msg.sender.transfer(valueToReturn);
  }
  // Override this method to have a way to add business logic to your crowdsale when buying
  function getTokenAmount(uint256 centValue) internal view returns(uint256) {
    return centValue.mul(getCurrentRate());
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds(uint256 value) internal {
    wallet.transfer(value);
  }

  function finishCrowdsale() public onlyOwner {
    require(centRaised > softCap);
    forwardFunds(this.balance);
    token.mint(foundersWallet,token.totalSupply().div(65).mul(35));
    token.finishMinting();
    token.transferOwnership(owner);
    endTime = now;
  }

  // set the address from which you can change the rate
  function setOracle(address _oracle) public  onlyOwner {
    require(_oracle != address(0));
    oracle = _oracle;
  }


  // set manager's address
  function setManager(address _manager) public  onlyOwner {
    require(_manager != address(0));
    manager = _manager;
  }

  function changePriceUSD(uint256 _priceUSD) public  onlyOracle {
    require(_priceUSD != 0);
    priceUSD = _priceUSD;
  }

  function getCurrentRate() public view returns (uint256) {
    uint256 elapsedTime = block.timestamp.sub(startTime).div(1 days);
    uint256 timeRange = 10;
    uint256 rateRange = initialRate.sub(finalRate);
    uint256 currentRange = initialRate.sub(elapsedTime.mul(rateRange).div(timeRange));
    if (elapsedTime >= 10) {
      currentRange = finalRate;
    }

    /**
    if (elapsedTime >= 10) {
      currentRange = finalRate;
    }
    else {
      currentRange = rates[elapsedTime];
    }
    */
    return currentRange;
  }





  //TODO add checks if its allowed
  function claimFreezedTokens(address claimer) public nonReentrant CanClaimNow {
    uint256 periodsPassed = now.sub(endTime).div(2592000);
    if (periodsPassed > 3) {
      periodsPassed = 3;
    }
    uint256 availableTokens = (claimableTokens[msg.sender].mul(periodsPassed)).sub(claimedTokens[claimer]);
    if (availableTokens + claimedTokens[claimer] > claimableTokens[claimer].mul(3)){
      availableTokens = claimableTokens[claimer].mul(3) - claimedTokens[claimer];
    }

    claimedTokens[claimer] = claimedTokens[claimer].add(availableTokens);
    token.transfer(claimer,availableTokens);
  }

  // manual selling tokens for fiat
  function manualTransfer(address _to, uint _valueUSD) public saleIsOn isUnderHardCap onlyOwnerOrManager {
    uint256 centValue = _valueUSD * 100;
    uint256 tokensAmount = getTokenAmount(centValue);
    centRaised = centRaised.add(centValue);
    //75% wiil be freezed
    token.mint(_to, tokensAmount.div(4));
    claimableTokens[msg.sender] += tokensAmount.div(4);
    token.mint(this, tokensAmount.mul(3));
    balancesInCent[_to] = balancesInCent[_to].add(centValue);
  }


  // low level token purchase function
  function buyTokens(address beneficiary) saleIsOn isUnderHardCap nonReentrant public payable {
    require(beneficiary != address(0) && msg.value != 0);
    require(whiteList.isInWhiteList(msg.sender));
    uint256 weiAmount = msg.value;
    uint256 centValue = weiAmount.div(priceUSD);
    uint256 tokensToSend = getTokenAmount(centValue).div(4);
    centRaised = centRaised.add(centValue);
    //75% wiil be freezed
    token.mint(beneficiary, tokensToSend);
    claimableTokens[msg.sender] += tokensToSend;
    token.mint(this, tokensToSend.mul(3));
    balances[msg.sender] = balances[msg.sender].add(weiAmount);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokensToSend);
    if (centRaised > softCap){
        forwardFunds(weiAmount);
    }

  }

  function () external payable {
    buyTokens(msg.sender);
  }
}









