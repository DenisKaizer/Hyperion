
const BigNumber = web3.BigNumber;


const Crowdsale = artifacts.require("./Crowdsale.sol");

const Token = artifacts.require('./HyperionWattToken.sol');
const WhiteList = artifacts.require('./WhiteList.sol');


contract('TestCrowdsale', function (accounts) {

    it("token's owner should be crowdsaleContract", async () => {
        let TokenInstance = await Token.deployed();
        await TokenInstance.transferOwnership(Crowdsale.address)
        let TokensOwner = await TokenInstance.owner.call();
        assert.equal(TokensOwner, Crowdsale.address);
    })

    it("sender transaction should be in white list", async () => {
        let TokenInstance = await Token.deployed();
        let CrowdsaleInstance = await Crowdsale.deployed();
        let WhiteListInstance = await WhiteList.deployed();

        try {
            await CrowdsaleInstance.sendTransaction({ value: 1e+18, from: accounts[1] })
            assert.fail()
        } catch (error) {
            err = error
        }
        assert.ok(err instanceof Error)
        console.log(err)

        let tokenBalance = await TokenInstance.balanceOf(accounts[1]).then(result => result.toNumber());
        let tokenBalance1 = tokenBalance;
        assert.equal(tokenBalance1, 0, "should be zero");

        console.log(tokenBalance1)

        let claimedTokens =  await CrowdsaleInstance.claimedTokens(accounts[1]).then(result => result.toNumber());
        console.log(claimedTokens)
        let claimableTokens =  await CrowdsaleInstance.claimableTokens(accounts[1]).then(result => result.toNumber());
        console.log(claimableTokens)

        await WhiteListInstance.addToWhiteList(accounts[1])

        let inWL = await WhiteListInstance.isInWhiteList(accounts[1]);

        assert.equal(inWL, true, "should be true");

        await CrowdsaleInstance.sendTransaction({ value: 1e+18, from: accounts[1] })
    })

    it("claimed freeze work correct", async () => {
        let TokenInstance = await Token.deployed();
        let CrowdsaleInstance = await Crowdsale.deployed();
        let WhiteListInstance = await WhiteList.deployed();

        await WhiteListInstance.addToWhiteList(accounts[2])

        await CrowdsaleInstance.sendTransaction({ value: 1e+18, from: accounts[2] })

        let tokenBalance = await TokenInstance.balanceOf(accounts[2]);
        let tokenBalance2 = tokenBalance.toNumber();
        console.log(tokenBalance2)

        claimedTokens =  await CrowdsaleInstance.claimedTokens(accounts[2]).then(result => result.toNumber());
        console.log(claimedTokens)
        
        claimableTokens =  await CrowdsaleInstance.claimableTokens(accounts[2]).then(result => result.toNumber());
        console.log(claimableTokens)

        assert.ok(claimedTokens < claimableTokens);
    })


})