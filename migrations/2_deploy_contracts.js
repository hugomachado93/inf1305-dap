var Chainclub = artifacts.require("Chainclub");

module.exports = function(deployer) {
  deployer.deploy(Chainclub, "Rodrigo");
  // Additional contracts can be deployed here
};
