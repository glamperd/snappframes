pragma solidity >=0.5.0;

// import "./dependencies/EdDSA.sol";
// import "./dependencies/JubJub.sol";
import '../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol';
// import "./dependencies/SafeMath.sol";

contract Verifier{

    function verifyProof(
            uint[2] memory a,
            uint[2] memory a_p,
            uint[2][2] memory b,
            uint[2] memory b_p,
            uint[2] memory c,
            uint[2] memory c_p,
            uint[2] memory h,
            uint[2] memory k,
            uint[39] memory input
    ) public returns (bool) {}

}

contract MiMC{

    function MiMCpe7(uint256,uint256,uint256,uint256) public pure returns (uint256) {}

}

// contract EdDSA{

//     function Verify( uint256[2] memory, uint256, uint256[2] memory, uint256 )
//         public view returns (bool) {}

// }


contract Snappframes is ERC721Full, Verifier, MiMC {

    using SafeMath for uint;
    using SafeMath for uint256; 

    // the tree has depth 6, i.e. 2^6 = 64 leaves
    uint256 public TREE_DEPTH = 6;

    // each segment has depth 3, i.e. 2^3 = 8 leaves
    uint256 public SEGMENT_DEPTH = 3;

    uint256 public NUM_SEGMENTS = 2**(TREE_DEPTH - SEGMENT_DEPTH);
    uint256 public NUM_LEAVES_PER_SEGMENT = 2**SEGMENT_DEPTH;

    uint256 TOTAL_FRAMES = 1000;
    uint256 PRICE_PER_FRAME = 1000;
    uint256 DEPOSIT_QUEUE_MAX = 2**TREE_DEPTH;

    Verifier verifier;
    MiMC mimc;
    // EdDSA eddsa;

    address public operator;

    uint256 public current_state;

    uint256 public depositQueueLength = 0;
    address[4] depositQueueAddresses;
    mapping(address => uint[2]) depositQueue;
    mapping(address => uint256[2]) public ecdsaToEddsa;


    event InitialRoot(uint256 _initialRoot);
    event Deposit(address _depositor, uint _segmentIdx, uint _leafIdx);
    event DepositsProcessed(address _firstDepositor, address _lastDepositor);

    event Leaf(uint256 _leaf);

    modifier depositQueueNotFull(){
        require(depositQueueLength <= DEPOSIT_QUEUE_MAX);
        _;
    }

    modifier operatorOnly(){
        require(msg.sender == operator);
        _;
    }

    constructor(
        address _verifierAddr,
        address _mimcAddr
        // address _eddsaAddr
    ) ERC721Full("Snappframes", "SNP") public {
        verifier = Verifier(_verifierAddr);
        mimc = MiMC(_mimcAddr);
        // eddsa = EdDSA(_eddsaAddr);

        operator = msg.sender;
    }

    function setInitialRoot(
        uint256 _initialRoot
    ) public operatorOnly{
        current_state = _initialRoot;

        emit InitialRoot(_initialRoot);
    }

    // performs state transition
    function update(
            uint[2] memory a,
            uint[2] memory a_p,
            uint[2][2] memory b,
            uint[2] memory b_p,
            uint[2] memory c,
            uint[2] memory c_p,
            uint[2] memory h,
            uint[2] memory k,
            uint[39] memory input
    ) public operatorOnly{
        require(verifier.verifyProof(
            a, a_p, b, b_p, c, c_p, h, k, input
        ));
    }

    // creates accounts for people who deposit Ether
    // @dev _from and _to are index ranges for movie frames
    function deposit(uint _index, uint256[2] memory _eddsaPubKey) 
    public payable depositQueueNotFull{

        require(msg.value >= PRICE_PER_FRAME);

        depositQueueLength++;
        depositQueueAddresses[depositQueueLength - 1] = msg.sender;

        // convert idx into segmentIdx, leaf idx (on segment)
        (uint segmentIdx, uint leafIdx) = getDivided(_index, NUM_LEAVES_PER_SEGMENT);
        
        depositQueue[msg.sender] = [segmentIdx, leafIdx];

        // assign msg.sender to declared eddsa address
        ecdsaToEddsa[msg.sender] = _eddsaPubKey;

        emit Deposit(msg.sender, segmentIdx, leafIdx);

    }

    // operator updates merkle tree with deposits
    function processDepositQueue() public operatorOnly{

        emit DepositsProcessed(
            depositQueueAddresses[0], 
            depositQueueAddresses[depositQueueAddresses.length - 1]);
        depositQueueLength = 0;
    }


    // allows withdraw of ERC721 token to Ethereum address
    // operator should process withdraws before transactions
    function withdraw(
        uint256 asset, 
        uint256[2] memory pubkey, //EdDSA pubKey_x and pubKey_y
        uint256[3] memory proof,
        uint256 root
        // uint256 hashed_msg, //hash of msg.sender and leaf
        // uint256[2] memory R, //EdDSA signature field
        // uint256 s //EdDSA signature field
    ) public {
        uint256[2] memory eddsaPubKey = ecdsaToEddsa[msg.sender];

        // // verify EdDSA signature
        // require(EdDSA.Verify(pubkey, hashed_msg, R, s));  

        require(eddsaPubKey[0] == pubkey[0] && eddsaPubKey[1] == pubkey[1]);

        // verify hashed msg sends leaf to msg.sender
        uint256 leaf = mimcHash(mimcHash(pubkey[0], pubkey[1]), asset);
        emit Leaf(leaf);
        
        // require(verifyMerkleProof(leaf, proof, root));
        // // require(mimc.MiMCpe7(msg.sender, leaf) == hashed_msg);

        // // generate ERC721 token
        // bytes32 tokenId = keccak256(abi.encodePacked(pubkey[0],pubkey[1]));
        // _mint(msg.sender, bytes32ToUint256(tokenId));

        // send token to depositor on Ethereum
    }
    
    // getters
    function getEddsaAddr(address _ethAddress) public view returns(uint256[2] memory){
        // uint256[2] memory eddsaAddr = ecdsaToEddsa[_ethAddress];
        return ecdsaToEddsa[_ethAddress];
    }


    // helpers

    function verifyMerkleProof(
        uint256 _leafHash,
        uint256[3] memory _merkleProof,
        uint256 _root
    ) public returns(bool){
        uint256[3] memory root;
        root[0] = mimcHash(_leafHash, _merkleProof[0]);
        for (uint i = 1; i < 3; i++) {             
            root[i] = mimcHash(root[i-1], _merkleProof[i]);
        }
        return(root[2] == _root);
    }

    function mimcHash(uint256 in_x, uint256 in_k) public returns(uint256){
        return mimc.MiMCpe7(in_x, in_k, uint256(keccak256("mimc")), 91);
    }


    // https://ethereum.stackexchange.com/questions/6498/how-to-convert-a-uint256-type-integer-into-a-bytes32
    function bytes32ToUint256(bytes32 n) internal returns (uint256) {
        return uint256(n);
    }

    function getDivided(uint numerator, uint denominator) public 
    returns(uint quotient, uint remainder) {
        quotient  = numerator / denominator;
        remainder = numerator - denominator * quotient;
    }
}

