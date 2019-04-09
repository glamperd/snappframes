const eddsa = require("../circomlib/src/eddsa.js");
const snarkjs = require("snarkjs");
const fs = require('fs');
const util = require('util');
const mimcjs = require("../circomlib/src/mimc7.js");

const bigInt = snarkjs.bigInt;

const DEPTH = 6;
const msg = bigInt(9999);

const prvKeyFrom = Buffer.from("0000000000000000000000000000000000000000000000000000000000000001", "hex");
const prvKeyTo = Buffer.from("0000000000000000000000000000000000000000000000000000000000000002", "hex");

const pubKeyFrom = eddsa.prv2pub(prvKeyFrom);
const assetHashes = [0,1,2,3,4,5,6,7];
const pathToSegment = [0,0,0];

const oldRoot = merkle(assetHashes, pubKeyFrom, pathToSegment);
console.log("Old Root")
console.log(oldRoot);

const msgHash = mimcjs.MultiHash(oldRoot, indexFrom, indexTo);
const signature = eddsa.signMiMC(prvKey, msgHash);

const newRoot = merkle(assetHashes, pubKeyTo, pathToSegment);

const inputs = {
      fromPubKey_x: pubKeyFrom[0].toString(),
      fromPubKey_y: pubKeyFrom[1].toString(),
			oldRootHash: oldRoot.toString(),
      newRootHash: newRoot.toString(),
			pathToSegment: [0, 0, 0],
      indexFrom: 0,
      indexTo: 7,
      R8x: signature.R8[0].toString(),
      R8y: signature.R8[1].toString(),
      S: signature.S.toString(),
    	nonce: 0,
      toPubKey_x: pubKeyTo[0].toString(),
      toPubKey_y: pubKeyTo[1].toSTring(),
      segmentAssets: assetHashes,
      segmentOwners: [pubKeyFrom,pubKeyFrom,pubKeyFrom,pubKeyFrom,pubKeyFrom,pubKeyFrom,pubKeyFrom,pubKeyFrom]
    }

console.log(inputs)

fs.writeFileSync('./input.json', JSON.stringify(inputs) , 'utf-8');

const new_hash = mimcjs.multiHash([pubKey[0],pubKey[1],nonce+1]);

console.log("New Root")
console.log(newRoot);

function merkle(assetHashes, pubKey, pathToSegment) {
  console.log(assetHashes)
  const hashes = assetHashes.map((item, key) => {
    return mimcjs.multiHash([pubKey[0],pubKey[1],item]);
  });
  console.log(hashes);

  var i;
  var l3Hashes;
  for (i=0; i<4; i++) {
      l3Hashes[i] = mimcjs.multiHash(hashes[i],hashes[i+1]);
  }
  var l2Hashes;
  for (i=0; i<2; i++) {
      l2Hashes[i] = mimcjs.multiHash(l3Hashes[i],l3Hashes[i+1]);
  }

  var tree = new Array(DEPTH-1);
  tree[0] = mimcjs.multiHash([l2Hashes[0],l2Hashes[1]]);

  for (i = 1; i < DEPTH-4; i++) {
    tree[i] = mimcjs.multiHash([tree[i-1],0]);
  }

  return tree[DEPTH-2];
}
