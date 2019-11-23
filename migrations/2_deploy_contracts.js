var HelloWorld = artifacts.require("Dao");

module.exports = function(deployer) {
    deployer.deploy(HelloWorld, "Dao");
    // Additional contracts can be deployed here
};