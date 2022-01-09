const Migrations = artifacts.require("kyc");

module.exports = function(deployer) {
  deployer.deploy(kyc);
};