const Web3 = require('web3')
const TruffleConfig = require('../truffle-config')
let FoodChain = artifacts.require('./FoodChain.sol')

module.exports = function(deployer, network, addresses) {
  const config = TruffleConfig.networks[network];

  if(process.env.ACCOUNT_PASSWORD) {
    // Unlock account before making deployment
    const web3 = new Web3(new Web3.providers.HttpProvider('http://' + config.host + ':' + config.port));

    console.log('Unlocking account ' + config.from);
    web3.personal.unlockAccount(config.from, process.env.ACCOUNT_PASSWORD, 36000);

  }

  deployer.deploy(FoodChain);
};

  