var Migrations = artifacts.require("./Migrations.sol");
// var EdDSA = artifacts.require("./dependencies/EdDSA.sol");
// var Verifier = artifacts.require("./Verifier.sol");
var verifierAddr = "0x338D3E24C43EC3d8365558785f34cb93f04b87c8";
var MiMC = artifacts.require("./dependencies/MiMC.sol");
var Snappframes = artifacts.require("./Snappframes.sol");

module.exports = function(deployer, accounts) {
    deployer.deploy(Migrations);

    deployer.deploy(MiMC).then(function() {
        return deployer.deploy(Snappframes, verifierAddr, MiMC.address);
    });

    
}
