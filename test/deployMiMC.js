const mimcGenContract = require("../circomlib/src/mimc_gencontract.js");

const Web3 = require('web3');
// const provider = ganache.provider();
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

const SEED = "mimc";

let mimc;
let accounts;

async function deployContract() {
  accounts = await web3.eth.getAccounts();

  mimc = await new web3.eth.Contract(mimcGenContract.abi)
    .deploy({data: mimcGenContract.createCode(SEED, 91)})
    .send({ from : accounts[0], gas: '6700000' })
};

deployContract();