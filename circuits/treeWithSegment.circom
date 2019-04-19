include "./hash2.circom";

// Full merkle tree (path + segment)
// d = full tree depth, s = segment depth
template TreeWithSegment6() {
    signal input pathToSegment[3];
    signal input segmentRootHash;
    //signal hashes[3];

    signal output rootHash;

    component levelHash[3];

    levelHash[0] = Hash2();
    levelHash[0].a <-- segmentRootHash;
    levelHash[0].b <-- pathToSegment[2];
    //levelHash[0].out === hashes[0];

    var i;
    for (i=1; i<3; i++) {
        levelHash[i] = Hash2();
        levelHash[i].a <-- levelHash[i-1].out;
        levelHash[i].b <-- pathToSegment[2-i];
    }
    rootHash <-- levelHash[2].out;
}
