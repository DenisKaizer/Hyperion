pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Presale.sol";
import "../contracts/HyperionWattToken.sol";
import "../contracts/WhiteList.sol";

contract TestHWT {

  HyperionWattToken HWT = HyperionWattToken(DeployedAddresses.HyperionWattToken());
  Presale preSaleInstance = Presale(DeployedAddresses.Presale());
  WhiteList whiteListInstance = WhiteList(DeployedAddresses.WhiteList());

  function testInitialBalanceUsingDeployedContract() public {


    address expected = DeployedAddresses.Presale();

    Assert.equal(HWT.owner(), expected, "Owner should be PresaleContract");
  }

  function testAddToWhiteList() public {

    bool expected = false;

    Assert.equal(whiteListInstance.isInWhiteList(msg.sender), expected, "should be false");

  }
}
