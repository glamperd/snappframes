const eddsa = require("../circomlib/src/eddsa.js");
const snarkjs = require("snarkjs");
const fs = require('fs');
const util = require('util');
const mimcjs = require("../circomlib/src/mimc7.js");

const bigInt = snarkjs.bigInt;

const DEPTH = 7;
const SEGMENT_DEPTH = 4;
const PATH_LENGTH = DEPTH - SEGMENT_DEPTH;
const msg = bigInt(9999);

/*
const hashAB = mimcjs.multiHash(0,1);
console.log('hash AB=', hashAB);
const hashBA = mimcjs.multiHash(1,0);
console.log('hash BA=', hashBA);
*/

const prvKeyFrom = Buffer.from("0000000000000000000000000000000000000000000000000000000000000001", "hex");
const prvKeyTo = Buffer.from("0000000000000000000000000000000000000000000000000000000000000002", "hex");
//console.log("private keys", prvKeyFrom, prvKeyTo);

const pubKeyFrom = eddsa.prv2pub(prvKeyFrom);
const assetHashes = [0,1,2,3,4,5,6,7];
const pathToSegment = [0,0,0];
const indexFrom = 0;
const indexTo = 7;

const oldRoot = merkle(assetHashes, pubKeyFrom, pathToSegment);
console.log("Old Root")
console.log(oldRoot);

const msgHash = mimcjs.multiHash([oldRoot.toString(), indexFrom.toString(), indexTo.toString()]);
console.log('msgHash', msgHash);
const signature = eddsa.signMiMC(prvKeyFrom, msgHash);
//console.log('signature', signature)

const pubKeyTo = eddsa.prv2pub(prvKeyTo);
const newRoot = merkle(assetHashes, pubKeyTo, pathToSegment);

const pk = [pubKeyFrom[0].toString(), pubKeyFrom[1].toString()];
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
      toPubKey_x: pubKeyTo[0].toString(),
      toPubKey_y: pubKeyTo[1].toString(),
      segmentAssets: assetHashes,
      segmentOwners: [pk,pk,pk,pk,pk,pk,pk,pk]
    }

// console.log(inputs)

fs.writeFileSync('./input.json', JSON.stringify(inputs) , 'utf-8');

const contractInputs = {
      EDDSA_0_DEC: [pubKeyFrom[0].toString(), pubKeyFrom[1].toString()],
      EDDSA_0_HEX: ['0x'+pubKeyFrom[0].toString(16), '0x'+pubKeyFrom[1].toString(16)],
      ASSET_0: assetHashes[0].toString(),
      OLD_LEAF_HASH: mimcjs.multiHash([pubKeyFrom[0].toString(),pubKeyFrom[1].toString(),assetHashes[0].toString()]).toString(),
      MERKLE_PROOF: [0,0,0],
      INITIAL_ROOT: oldRoot.toString()
}

fs.writeFileSync('../contracts/contractInput.json',JSON.stringify(contractInputs), null, " ");

//const new_hash = mimcjs.multiHash([pubKey[0],pubKey[1],nonce+1]);

//console.log("New Root")
//console.log(newRoot);

function merkle(assetHashes, pubKey, pathToSegment) {
  console.log(assetHashes)
  const hashes = assetHashes.map((item, key) => {
    return mimcjs.multiHash([BigInt(pubKey[0]).toString(),BigInt(pubKey[1]).toString(),item.toString()]);
  });
  console.log(hashes);

  var i;
  var l3Hashes = new Array(4);
  for (i=0; i<4; i++) {
      l3Hashes[i] = mimcjs.multiHash([BigInt(hashes[i*2]).toString(),BigInt(hashes[i*2+1]).toString()]);
      //console.log('hash',i,hashes[i*2] )
  }
  var l2Hashes = new Array(2);
  for (i=0; i<2; i++) {
      l2Hashes[i] = mimcjs.multiHash([BigInt(l3Hashes[2*i]).toString(),BigInt(l3Hashes[2*i+1]).toString()]);
      //console.log('l2 hash',i,hashes[i*2] )
  }
  //console.log('l2 hashes', l2Hashes.toString());

  var tree = new Array(DEPTH-1);
  tree[0] = mimcjs.multiHash([BigInt(l2Hashes[0]).toString(),BigInt(l2Hashes[1]).toString()]);
  console.log('tree0', tree[0]);

  for (i = 0; i < PATH_LENGTH; i++) {
    tree[i+1] = mimcjs.multiHash([BigInt(tree[i]).toString(),pathToSegment[i].toString()]);
    console.log('path hash', tree[i+1])
  }

  //console.log('tree', tree)
  return tree[PATH_LENGTH];
}
