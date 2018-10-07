var Adoption = artifacts.require("./Adoption.sol");
var TeamUp = artifacts.require("./TeamUp.sol");

module.exports = function(deployer) {
  deployer.deploy(Adoption);
  deployer.deploy(TeamUp);
};
