pragma solidity ^0.4.18;

import "./Ownable.sol";

contract WhiteList is Ownable {
    
  mapping(address => bool) public accreditedInvestor;
  mapping(address => bool) public crowdsaleMangers;
    
  modifier onlyCrowdsaleManagerOrOwner() {
    require(crowdsaleMangers[msg.sender] || owner == msg.sender);
    _;
  }
    
  function WhiteList(address _crowdsaleManager) public { 
    crowdsaleMangers[_crowdsaleManager] = true;     
  }
    
    
  function addToWhiteList(address _investor) public onlyCrowdsaleManagerOrOwner  {
    accreditedInvestor[_investor] = true;
  }
  
  function addCrowdsaleManager(address _crowdsaleManager) onlyOwner {
    crowdsaleMangers[_crowdsaleManager] = true;
  }

  function removeFromWhiteList(address _badInvestor) public onlyCrowdsaleManagerOrOwner  {
    accreditedInvestor[_badInvestor] = false;
  }

  function isInWhiteList(address _sender) view public returns(bool){
    return(accreditedInvestor[_sender]);
  }
}
