include "./hash2.circom";

// Full merkle tree (path + segment)
// d = full tree depth, s = segment depth
template TreeWithSegment6() {
    signal input pathToSegment[3];
    signal input segmentRootHash;

    signal output rootHash;

    component levelHash[3];
    var lastHash = segmentRootHash;
    var i;
    for (i=0; i<3; i++) {
        levelHash[i] = Hash2();
        levelHash[i].a <== lastHash;
        levelHash[i].b <== pathToSegment[2-i];
        lastHash <== levelHash[i].out;
    }
    rootHash <== lastHash;
}
