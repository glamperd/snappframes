var Migrations = artifacts.require("./Migrations.sol");
// var EdDSA = artifacts.require("./dependencies/EdDSA.sol");
// var Verifier = artifacts.require("./Verifier.sol");
var verifierAddr = "0x05bd365d73011dae4e28e4607f654e54611ea09f";
var MiMC = artifacts.require("./dependencies/MiMC.sol");
var Snappframes = artifacts.require("./Snappframes.sol");

module.exports = function(deployer, accounts) {
    deployer.deploy(Migrations);

    deployer.deploy(MiMC).then(function() {
        return deployer.deploy(Snappframes, verifierAddr, MiMC.address);
    });

    
}
