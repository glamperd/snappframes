include "../circomlib/circuits/mimc.circom";
include "./hash2.circom";

// Merkle tree segment of depth 3
template TreeSegment8() {
    signal input leafHashes[8];

    signal level2[4];
    signal level1[2];

    signal output rootHash;

    component hash[8];
    var numLeaves = 8;
    var i;
    for (i=0; i<4; i++) {
      hash[i] = Hash2();
      hash[i].a <== leafHashes[i*2];
      hash[i].b <== leafHashes[i*2+1];
      level2[i] <== hash[i].out;
    }

    component hash2[4];
    for (i=0; i<2; i++) {
      hash2[i] = Hash2();
      hash2[i].a <== level2[i*2];
      hash2[i].b <== level2[i*2+1];
      level1[i] <== hash2[i].out;
    }

    component rh = Hash2();
    rh.a <== level1[0];
    rh.b <== level1[1];
    rh.out ==> rootHash;
}
