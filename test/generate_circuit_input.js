const eddsa = require("../circomlib/src/eddsa.js");
const mimcjs = require("../circomlib/src/mimc7.js");
const fs = require("fs");
const account = require("./utils/generate_accounts.js");
const leaf = require("./utils/generate_leaf.js");
const merkle = require("./utils/MiMCMerkle.js");

const NUM_LEAF = 8;

function stringifyArray(array){
    arrayString = []
    for (i = 0; i < array.length; i++){
        arrayString.push(array[i].toString())
    } 
    return arrayString
}

function stringifyAssetsArray(assetsArray){
    assetsArrayString = []
    for (i = 0; i < assetsArray.length; i++){
        assetsArrayString.push(BigInt('0x'+assetsArray[i]).toString())
    } 
    return assetsArrayString
}

function stringifyMatrixElements(matrix){
    matrixString = []
    for (i = 0; i <  matrix.length; i++){
        matrixString.push([matrix[i][0].toString(), matrix[i][1].toString()])
    }
    return matrixString
}

prvKeys = account.generatePrvKeys(NUM_LEAF);
pubKeys = account.generatePubKeys(prvKeys);

rawAssets = fs.readFileSync("../assets/hashes.json")
assets = JSON.parse(rawAssets)

// initialise tree with one-to-one linear mapping of ownership (WLOG)
let leafHashArray = [];

for (i = 0; i < NUM_LEAF; i++){
    leafHash = mimcjs.multiHash(
        [pubKeys[i][0].toString(), pubKeys[i][1].toString(), BigInt('0x'+assets[i]).toString()]
    );
    leafHashArray.push(leafHash);    
}

console.log("oldLeafHash: ", leafHashArray[0])

let [layer1, layer2, oldRoot] = merkle.rootFrom8LeafArray(leafHashArray);
console.log("oldRoot: ", oldRoot)
let merklePath = [leafHashArray[1], layer1[1], layer2[1]];

let indexFrom = 0;
let indexTo = 7;

//transfer index 0 from acct 0 to acct 1
let msgHash = mimcjs.multiHash(
    [oldRoot.toString(), indexFrom, indexTo]
)
let signature = eddsa.signMiMC(prvKeys[0], msgHash)

// update leafHashArray
 let newLeafHashArray = leafHashArray;
 let newLeafHash = mimcjs.multiHash(
     [pubKeys[1][0].toString(), pubKeys[1][1].toString(), BigInt('0x'+assets[0]).toString()]
 );
console.log("newLeafHash: ", newLeafHash)

 newLeafHashArray[0] = newLeafHash;

let [newLayer1, newLayer2, newRoot] = merkle.rootFrom8LeafArray(newLeafHashArray);
console.log("newRoot: ",newRoot)


const inputs = {
    fromPubKey_x: pubKeys[0][0].toString(),  
    fromPubKey_y: pubKeys[0][1].toString(),   
    oldRootHash: oldRoot.toString(),
    newRootHash: newRoot.toString(),
    indexFrom: indexFrom,
    indexTo: indexTo,
    toPubKey_x: pubKeys[1][0].toString(),  
    toPubKey_y: pubKeys[1][1].toString(),   
    segmentAssets: stringifyAssetsArray(assets),
    segmentOwners: stringifyMatrixElements(pubKeys),
    pathToSegment: stringifyArray(merklePath),
    R8x: signature.R8[0].toString(),
    R8y: signature.R8[1].toString(),
    S: signature.S.toString()
}

fs.writeFileSync(
"../circuits/input.json",
JSON.stringify(inputs),
"utf-8"
);


