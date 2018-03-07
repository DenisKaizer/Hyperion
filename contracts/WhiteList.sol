pragma solidity ^0.4.18;

import "./Ownable.sol";

contract WhiteList is Ownable {
    
    mapping(address => bool) public accreditedInvestor;
    address crowdsaleManager ;
    
    modifier onlyCrowdsaleManagerOrOwner() {
    require(crowdsaleManager == msg.sender || owner == msg.sender);
    _;
  }
    
    function WhiteList(address _crowdsaleManager) public {
        
        crowdsaleManager =_crowdsaleManager;    
        
    }
    
    
    function addToWhiteList(address _investor) public onlyCrowdsaleManagerOrOwner  {
    accreditedInvestor[_investor] = true;
  }

  function removeFromWhiteList(address _badInvestor) public onlyCrowdsaleManagerOrOwner  {
    accreditedInvestor[_badInvestor] = false;
   
  }
}
