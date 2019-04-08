include "../circomlib/circuits/mimc.circom";

template Leaf() {
    signal input pubkey_x;
    signal input pubkey_y;
    signal input asset;
    signal output hash;

    component leaf_hash = MultiMiMC7(3, 91);
    leaf_hash.in[0] <== pubkey_x;
    leaf_hash.in[1] <== pubkey_y;
    leaf_hash.in[2] <== asset;
    hash <== leaf_hash.out;
}
