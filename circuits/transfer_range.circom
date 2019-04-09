include "../circomlib/circuits/mimc.circom";
include "../circomlib/circuits/eddsamimc.circom";
include "../circomlib/circuits/bitify.circom";
include "../circomlib/circuits/comparators.circom";
include "./leaf.circom";
include "./hash2.circom";
include "./tree_segment.circom";
include "./treeWithSegment.circom";

template Main() {
    signal input fromPubKey_x;
    signal input fromPubKey_y;
    signal input oldRootHash;
    signal input newRootHash;
    signal input indexFrom;
    signal input indexTo;
    signal input toPubKey_x;
    signal input toPubKey_y;
    signal input segmentAssets[8];
    signal input segmentOwners[8,2];
    signal input pathToSegment[3]; // Sibling hashes along the path
    // EdDSA verifier params
    signal input R8x;
    signal input R8y;
    signal input S;

    signal output out;


    // Assemble leaves for the segment.
    var i;
    component leaves[8];
    for (i=0; i<8; i++) {
        leaves[i] = Leaf();
        leaves[i].pubkey_x <== segmentOwners[i,0];
        leaves[i].pubkey_y <== segmentOwners[i,1];
        leaves[i].asset <== segmentAssets[i];
    }

    // Build segment
    component oldSegment = TreeSegment8();
    for (i=0; i<8; i++) {
      oldSegment.leafHashes[i] <== leaves[i].hash;
    }

    // Assemble full tree (path + segment)
    // Build full path including the segment. Calculate old root hash.
    component old_tree = TreeWithSegment6();
    for (i=0; i<3; i++) {
      old_tree.pathToSegment[i] <== pathToSegment[i];
    }
    old_tree.segmentRootHash <== oldSegment.rootHash;

    oldRootHash === old_tree.rootHash;

    // Confirm signatures
    component verifier = EdDSAMiMCVerifier();
    verifier.enabled <== 0;
    verifier.Ax <== fromPubKey_x;
    verifier.Ay <== fromPubKey_y;
    verifier.R8x <== R8x
    verifier.R8y <== R8y
    verifier.S <== S;

    component msgHash = MultiMiMC7(3,91);
    msgHash.in[0] <== oldRootHash;
    msgHash.in[1] <== indexFrom;
    msgHash.in[2] <== indexTo;
    verifier.M <== msgHash.out;

    // Confirm ownership & Replace owner
    //component compareAcc[8];

    for (i=0; i<8; i++) {
        //compareAcc[i] = IsEqual();
        if (i>=indexFrom && i<=indexTo) {
            fromPubKey_x === segmentOwners[i,0];
            fromPubKey_y === segmentOwners[i,1];
            //compareAcc[i].in[0] <== segmentOwners[i,0];
            //compareAcc[i].in[1] <== segmentOwners[i,1];
        }
        //else {
            // Redundant, but an assignment must be made once declared
            //compareAcc[i].in[0] <== 1;
            //compareAcc[i].in[1] <== 1;
        //}
        //authOk[i] <== compareAcc[i].out;
    }


    component newLeaves[8];

    for (i=0; i<8; i++) {
        newLeaves[i] = Leaf();
        if (i>=indexFrom && i<=indexTo) {
            newLeaves[i].pubkey_x <-- toPubKey_x;
            newLeaves[i].pubkey_y <-- toPubKey_y;
        } else {
            newLeaves[i].pubkey_x <-- segmentOwners[i,0];
            newLeaves[i].pubkey_y <-- segmentOwners[i,1];
        }
        newLeaves[i].asset <-- segmentAssets[i];
    }

    // Calculate new segment
    component newSegment = TreeSegment8();
    for (i=0; i<8; i++) {
        newSegment.leafHashes[i] <== newLeaves[i].hash;
    }

    component new_tree = TreeWithSegment6();
    for (i=0; i<3; i++) {
      new_tree.pathToSegment[i] <== pathToSegment[i];
    }
    new_tree.segmentRootHash <== newSegment.rootHash;

    new_tree.rootHash --> out;
    newRootHash === new_tree.rootHash;

}

component main = Main();
