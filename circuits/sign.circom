include "../circomlib/circuits/mimc.circom";
include "../circomlib/circuits/eddsamimc.circom";

template Main() {
    signal input fromPubKey_x;
    signal input fromPubKey_y;
    signal input oldRootHash;
    signal input indexFrom; // Start frame with tree segment 0-7
    signal input indexTo; // Transfer up to this frame number 0-7
    // EdDSA verifier params
    signal input R8x;
    signal input R8y;
    signal input S;

    //signal output out;

    // Confirm signatures
    component verifier = EdDSAMiMCVerifier();
    // TODO - Set this to 1 when it's working
    verifier.enabled <-- 1;
    verifier.Ax <-- fromPubKey_x;
    verifier.Ay <-- fromPubKey_y;
    verifier.R8x <-- R8x
    verifier.R8y <-- R8y
    verifier.S <-- S;

    component msgHash = MultiMiMC7(3,91);
    msgHash.in[0] <-- oldRootHash;
    msgHash.in[1] <-- indexFrom;
    msgHash.in[2] <-- indexTo;
    verifier.M <-- msgHash.out;

}

component main = Main();
