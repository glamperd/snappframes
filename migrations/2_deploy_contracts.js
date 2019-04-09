var Migrations = artifacts.require("./Migrations.sol");

var verifierAddr = "0xFD198266A94fB2e02a3B674c0A1DbB78c376A307";
var mimcAddr = "0x75f151b948fbc0ee3c8372606c7b7819726afcc9";

var Snappframes = artifacts.require("./Snappframes.sol");

module.exports = function(deployer, accounts) {
    deployer.deploy(Migrations);

    deployer.deploy(Snappframes, verifierAddr, mimcAddr);
    
}
