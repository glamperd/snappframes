const mimcjs = require("../../circomlib/src/mimc7.js");


module.exports = {

    rootFromLeafAndPath: function(depth, leaf, merkle_path, merkle_path_pos){
        if (depth == merkle_path.length + 1){
            var root = new Array(depth - 1);
            left = leaf - BigInt(merkle_path_pos[0])*(leaf - BigInt(merkle_path[0]));
            right = BigInt(merkle_path[0]) - BigInt(merkle_path_pos[0])*(BigInt(merkle_path[0]) - leaf);
            root[0] = mimcjs.multiHash([left, right]);
            var i;
            for (i = 1; i < depth - 1; i++) {
                left = root[i-1] - BigInt(merkle_path_pos[i])*(root[i-1] - BigInt(merkle_path[i]));
                right = BigInt(merkle_path[i]) - BigInt(merkle_path_pos[i])*(BigInt(merkle_path[i]) - root[i-1]);              
                root[i] = mimcjs.multiHash([left, right]);
            }
        } else {
            console.log("Merkle path is of length ", merkle_path.length, 
            "when it should be length ", depth - 1)
        }
        return root[depth - 2];
    },

    rootFrom8LeafArray: function(leafArray){
        if (leafArray.length == 8){
            layer1 = []
            for (i = 0; i < 4; i++){
                let hash = mimcjs.multiHash([leafArray[2*i].toString(), leafArray[2*i+1].toString()])
                layer1.push(hash);
            }
            layer2 = []
            for (i = 0; i < 2; i++){
                let hash = mimcjs.multiHash([layer1[2*i].toString(), layer1[2*i+1].toString()])
                layer2.push(hash);
            }
            var root = mimcjs.multiHash([layer2[0].toString(), layer2[1].toString()]);
        } else {
            console.log("This only works for trees with 8 leaves")
        }
        return [layer1, layer2, root]
    }

}