//include "../circomlib/circuits/mimc.circom";
//include "../circomlib/circuits/eddsamimc.circom";
//include "../circomlib/circuits/bitify.circom";
//include "../circomlib/circuits/comparators.circom";
include "./leaf.circom";
include "./hash2.circom";
include "./tree_segment.circom";
include "./treeWithSegment.circom";

template Main() {
    signal input oldRootHash;
    signal input segmentAssets[8];
    signal input segmentOwners[8,2]; // Owner pub key x, y
    signal input pathToSegment[3]; // Sibling hashes along the path
    signal input leafHash0;
    signal input pathHashes[3];

    signal input segRoot;

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
    leaves[0].hash === leafHash0;

    // Build segment
    component oldSegment = TreeSegment8();
    for (i=0; i<8; i++) {
      oldSegment.leafHashes[i] <-- leaves[i].hash;
    }
    segRoot === oldSegment.rootHash;

    // Assemble full tree (path + segment)
    // Build full path including the segment. Calculate old root hash.
    component old_tree = TreeWithSegment6();
    old_tree.segmentRootHash <-- oldSegment.rootHash;
    old_tree.hashes[0] <-- pathHashes[0];
    for (i=0; i<3; i++) {
      old_tree.pathToSegment[i] <== pathToSegment[i];
      old_tree.hashes[i] <-- pathHashes[i];
    }
    oldRootHash === old_tree.rootHash;
    old_tree.rootHash --> out;
}

component main = Main();
