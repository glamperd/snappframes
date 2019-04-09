let accounts = await web3.eth.getAccounts()
let snappframes = await Snappframes.deployed()

const PRICE_PER_FRAME = 1000
EDDSA_0 = ["0xc92859506d52a579ab5073c239985d70a7eec5664d0f2bab72ab62133d1405c","0x2da8e567f1f42da127151b8857e2c3bca230b4efa89889e437133a3a82548753"]
ASSET_0 = 0
OLD_LEAF_HASH = "8908823339211333967094228751103816659137581822508919706452078135208302381752"
MERKLE_PROOF = [0,0,0]
INITIAL_ROOT = "13295470590686955219033734677882891113436889936925570779790805879116714000031"

let deposit = await snappframes.deposit( 0, EDDSA_0,{from: accounts[0], value: PRICE_PER_FRAME*10})
let getEddsaAddr = await snappframes.getEddsaAddr(accounts[0], {from: accounts[0]})

getEddsaAddr.logs[0]

let processDepositQueue = await snappframes.processDepositQueue({from: accounts[0]})

let setInitialRoot = await snappframes.setInitialRoot(INITIAL_ROOT, {from: accounts[0]})

let verifyMerkleProof = await snappframes.verifyMerkleProof(OLD_LEAF_HASH, MERKLE_PROOF, INITIAL_ROOT,{from: accounts[1]})

let withdraw = await snappframes.withdraw(ASSET_0, EDDSA_0, MERKLE_PROOF, INITIAL_ROOT, {from: accounts[0]})

