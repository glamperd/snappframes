const eddsa = require("../circomlib/src/eddsa.js");
const mimcjs = require("../circomlib/src/mimc7.js");
const fs = require("fs");
const account = require("./utils/generate_accounts.js");
const leaf = require("./utils/generate_leaf.js");
const merkle = require("./utils/MiMCMerkle.js");

const NUM_LEAF = 8;

prvKeys = account.generatePrvKeys(NUM_LEAF);
pubKeys = account.generatePubKeys(prvKeys);
pathToSegment = [0, 0, 0];

rawAssets = fs.readFileSync("../assets/hashes.json")
// assets = JSON.parse(rawAssets)
assets = [0,1,2,3,4,5,6,7]

// initialise tree with all assets owned by account[0]
let leafHashArray = [];

for (i = 0; i < NUM_LEAF; i++){
    leafHash = mimcjs.multiHash(
        [BigInt(pubKeys[0][0]).toString(), BigInt(pubKeys[0][1]).toString(), assets[i]]
    );
    leafHashArray.push(leafHash);    
}

let [layer1, layer2, oldSegmentRoot] = merkle.rootFrom8LeafArray(leafHashArray);
console.log('tree0', oldSegmentRoot)

var oldTree = new Array(4);
oldTree[0] = oldSegmentRoot
for (i = 1; i < 4; i++) {
  oldTree[i] = mimcjs.multiHash([BigInt(oldTree[i-1]).toString(),pathToSegment[i-1].toString()]);
}

oldRoot = oldTree[3]

console.log("old root: ", oldRoot)

let indexFrom = 0;
let indexTo = 7;

//transfer index 0 from acct 0 to acct 1
let msgHash = mimcjs.multiHash(
    [oldRoot.toString(), indexFrom.toString(), indexTo.toString()]
)
let signature = eddsa.signMiMC(prvKeys[0], msgHash)

// update leafHashArray
 let newLeafHashArray = [];
 for (i = 0; i < NUM_LEAF; i++){
    newLeafHash = mimcjs.multiHash(
        [BigInt(pubKeys[1][0]).toString(), BigInt(pubKeys[1][1]).toString(), assets[i]]
    );
    newLeafHashArray.push(newLeafHash);    
}

let [newLayer1, newLayer2, newSegmentRoot] = merkle.rootFrom8LeafArray(newLeafHashArray);

var newTree = new Array(4);
newTree[0] = newSegmentRoot
for (i = 1; i < 4; i++) {
  newTree[i] = mimcjs.multiHash([BigInt(newTree[i-1]).toString(),pathToSegment[i-1].toString()]);
}

newRoot = newTree[3]

console.log('tree0', newSegmentRoot)
console.log("newRoot: ",newRoot)

const pk = [pubKeys[0][0].toString(), pubKeys[0][1].toString()];

const inputs = {
    fromPubKey_x: pubKeys[0][0].toString(),  
    fromPubKey_y: pubKeys[0][1].toString(),   
    oldRootHash: oldRoot.toString(),
    newRootHash: newRoot.toString(),
    indexFrom: indexFrom,
    indexTo: indexTo,
    toPubKey_x: pubKeys[1][0].toString(),  
    toPubKey_y: pubKeys[1][1].toString(),   
    segmentAssets: assets,
    segmentOwners: [pk,pk,pk,pk,pk,pk,pk,pk],
    pathToSegment: pathToSegment,
    R8x: signature.R8[0].toString(),
    R8y: signature.R8[1].toString(),
    S: signature.S.toString()
}

fs.writeFileSync(
"../circuits/input.json",
JSON.stringify(inputs),
"utf-8"
);

  