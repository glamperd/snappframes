var Migrations = artifacts.require("./Migrations.sol");
var EdDSA = artifacts.require("./dependencies/EdDSA.sol");
var MiMC = artifacts.require("./dependencies/MiMC.sol");
var Snappframes = artifacts.require("./Snappframes.sol");

module.exports = function(deployer, accounts) {
    deployer.deploy(Migrations);

    deployer.deploy(EdDSA).then(function() {
      return deployer.deploy(MiMC).then(function() {
        return deployer.deploy(Snappframes, MiMC.address, EdDSA.address);
      })
    });

    
}
