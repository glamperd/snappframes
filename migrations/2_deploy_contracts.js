var Migrations = artifacts.require("./Migrations.sol");
var EdDSA = artifacts.require("./dependencies/EdDSA.sol")
var Snappframes = artifacts.require("./Snappframes.sol")

var mimcAddr = '0x5b671b3d524aa8857d72c9dd18c7c8617d7cff61';

module.exports = function(deployer, accounts) {
    deployer.deploy(Migrations);
    deployer.deploy(EdDSA).then(() => {
      return deployer.deploy(Snappframes, mimcAddr, EdDSA.address);
    });
}
