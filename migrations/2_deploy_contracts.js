var Presale = artifacts.require("./Presale.sol");
var Crowdsale = artifacts.require("./Crowdsale.sol");
var HWT = artifacts.require("./HyperionWattToken.sol");
var WhiteList = artifacts.require("./WhiteList.sol");
var unix = Math.round(+new Date()/1000);

var crowdsaleManager = '0x6B35d857486800768b5878eE2F827D7046a7dd6E';
var wallet = '0x6B35d857486800768b5878eE2F827D7046a7dd6E';
var foundersWallet = '0x6B35d857486800768b5878eE2F827D7046a7dd6E';

module.exports = function(deployer) {
  deployer.deploy(HWT).then(function () {
      return deployer.deploy(WhiteList, crowdsaleManager);
  }).then(function () {
      return deployer.deploy(Presale, unix, 10, wallet , HWT.address, 13692121690100, WhiteList.address);
  }).then(function () {
      return deployer.deploy(Crowdsale, unix, 10, wallet, foundersWallet , HWT.address, 13692121690100, WhiteList.address);
  })
};


//"0x9f59967eb0aac08b1eb48644ecc04951fd187449", "0x414b516122e3d60943b9697c38c1352e2353faae", 16513503917828, "0xc96572662315067b14c24121c187a65c842ab3f8"