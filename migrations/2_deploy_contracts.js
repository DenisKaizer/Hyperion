var Presale = artifacts.require("./Presale.sol");
var Crowdsale = artifacts.require("./Crowdsale.sol");
var HWT = artifacts.require("./HyperionWattToken.sol");
var WhiteList = artifacts.require("./WhiteList.sol");
var unix = Math.round(+new Date()/1000);

module.exports = function(deployer) {
  deployer.deploy(HWT);
  deployer.deploy(WhiteList, '0x627306090abab3a6e1400e9345bc60c78a8bef57' ).then(function () {
      return deployer.deploy(Presale, unix, 1, '0x627306090abab3a6e1400e9345bc60c78a8bef57' , HWT.address, 13692121690100, WhiteList.address)
  }).then(function () {
      return deployer.deploy(Crowdsale, unix, 1, '0x627306090abab3a6e1400e9345bc60c78a8bef57','0x627306090abab3a6e1400e9345bc60c78a8bef57' , HWT.address, 13692121690100, WhiteList.address);
  })
};
