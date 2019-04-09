var Migrations = artifacts.require("./Migrations.sol");

var verifierAddr = "0xEd3564b7377b90fad536e428e54d856E6928b4dA";
var mimcAddr = "0x75f151b948fbc0ee3c8372606c7b7819726afcc9";

var Snappframes = artifacts.require("./Snappframes.sol");

module.exports = function(deployer, accounts) {
    deployer.deploy(Migrations);

    deployer.deploy(Snappframes, verifierAddr, mimcAddr);
    
}
