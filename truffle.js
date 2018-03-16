var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "nerve clever boil cube same robust genre floor between goat cheese lady";

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 7545,
      network_id: 5777 // Match any network id
    },
    ropsten: {
        provider: function() {
          return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/PNBAkpo8ozY9YxcN5EcS")
        },
        network_id: 3,
        gas: 4612388,
        gasPrice: 22000000000
    }
  }
};

