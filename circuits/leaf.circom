include "../circomlib/mimc.circom";
//include "../circomlib/eddsamimc.circom";
include "./hash2.circom";

template Leaf() {
    signal input pubkey;
    signal input asset;
    signal output hash;

    component leaf_hash = Hash2();
    leaf_hash.a <== pubkey;
    leaf_hash.b <== asset;
    hash <== leaf_hash.out;
}
