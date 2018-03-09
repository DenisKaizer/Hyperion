
<img width="240" height ="240" align="center" alt="Hyperion" src = "./assets/Hyperion.jpg">

# Hyperion Fund Smart Contracts

# Project descruption 
Hyperion Token - Сonstruction of solar power stations.

Hyperion Token  is 1 Watt distributed among grid

# Dependencies 
[![truffle](https://img.shields.io/badge/truffle-v3.4.11-orange.svg)](https://truffle.readthedocs.io/en/latest/)
[![solidity](https://img.shields.io/badge/solidity-docs-red.svg)](http://solidity.readthedocs.io/en/develop/types.html)

# Smart contracts

## [HyperionWattToken](https://github.com/DenisKaizer/Hyperion/blob/master/contracts/HyperionWattToken.sol)
ERC20 mintable token with additional overridings to create a  possibility to issue a dividends in form of a HyperionWattCoin

Token | Parameters
------------ | -------------
Token name	| Hyperion Watt Token
Symbol 	 | HWT
Decimals |	18
Token amount to issue |	250 000 000 (incl 8% tokens hold by Hyperion Fund)
Additional token emission |	no
Freeze tokens | 	25% in first 3 months after ICO, 50% in 6 months after ICO, 75% in 9 months after ICO, 100% in 12 months after ICO.  

## [Hyperion WhiteList](https://github.com/DenisKaizer/Hyperion/blob/master/contracts/WhiteList.sol)

In order to participate in HWT Presale or a Crowdsale you have to walkthrough KYC Process and get to whitelist
Whitelist is managed by its owner and a CrowdsaleManager

## [Hyperion presale](https://github.com/DenisKaizer/Hyperion/blob/master/contracts/HWTPresale.sol)
Basic Parameters of Presale

First Header | Second Header
------------ | -------------
Token price in ETH	| automatic calculation based on price $0,6 per Token
Automatic rate change |	yes
Presale bonuses/discounts |	25% in-kind token bonus ~ 20% discount to ICO price (min. $10000)
Success terms	184 000 000 tokens + 25% in-kind bonus | 230 000 000 (presale hardcap)
Refund Terms	| no
Withdrawal terms |	Real-time
Manual token issue (if founders accepts BTC/USD/EURO) |	yes

## [Hyperion crowdsale](https://github.com/DenisKaizer/Hyperion/blob/master/contracts/HWTCrowdsale.sol)

First Header | Second Header
------------ | -------------
Total amount of tokens to be sold	| 250 million less token number sold at presale
Token price in ETH	 | automatic calculation based on price $0,6 per Token
Automatic rate change | 	yes
Success terms |	250 000 000 less 20 000 000 (8% to Hyperion Fund) less presale tokens
Refund Terms	| yes if less than $5 000 000 is collected
Withdrawal terms |	Real-time
Manual token issue (if founders accepts BTC/USD/EURO)	| yes



# Token issuance process walkthrough

# Created by 

<img width="240" height ="240" alt="Hyperion" src = "./assets/Hashlab.jpg">
