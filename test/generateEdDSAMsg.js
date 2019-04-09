const eddsa = require("./circomlib/src/eddsa.js");
const mimcjs = require("./circomlib/src/mimc7.js");
const fs = require("fs");

const prvKey = Buffer.from("1".padStart(64,'0'), "hex");
const pubKey = eddsa.prv2pub(prvKey);
console.log(pubKey);
const asset = 1;

const recipient = 0xcEB2F222039BE0Df7F34923B9AC5fcAC80F15C15;
const leaf = mimcjs.multiHash([pubKey[0], pubKey[1], asset]);
const msgHash = mimcjs.multiHash([recipient, leaf]);
console.log(msgHash);

// Alice signs old leaf
const signature = eddsa.sign(prvKey, Buffer.from(msgHash, "hex"));
console.log(signature);

const inputs = {
    asset: asset.toString(),
    pubkey: [pubKey[0].toString(), pubKey[1].toString()],
    hashed_msg: msgHash.toString(),
    R: [signature.R8[0].toString(), signature.R8[1].toString()],
    s: signature.S.toString()
}

fs.writeFileSync(
"./eddsa_example.json",
JSON.stringify(inputs, null, 2),
"utf-8"
);