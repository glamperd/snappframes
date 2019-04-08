pragma solidity >=0.5.0;

// import "./dependencies/EdDSA.sol";
import "./dependencies/JubJub.sol";
import '../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol';
// import "./dependencies/SafeMath.sol";

// contract Verifier{

//     function Verify() public {}

// }

contract MiMC{

    function MiMCpe7(uint,uint) public pure returns (uint) {}

}

contract EdDSA{

    function Verify( uint256[2] memory, uint256, uint256[2] memory, uint256 )
        public view returns (bool) {}

}


contract Snappframes is ERC721Full, EdDSA, MiMC {

    using SafeMath for uint;
    using SafeMath for uint256; 

    uint public TREE_DEPTH = 6;

    // Verifier verifier;
    MiMC mimc;
    EdDSA eddsa;

    address operator = msg.sender;
    uint TOTAL_FRAMES = 1000;
    uint PRICE_PER_FRAME = 1000;
    uint DEPOSIT_QUEUE_MAX = 4;
    uint depositQueueLength = 0;
    address[4] depositQueueAddresses;
    mapping(address => uint) depositQueue;
    mapping(address => uint256[2]) public ecdsaToEddsa;

    event Deposit(address _depositor, uint _index);
    event DepositsProcessed(address _firstDepositor, address _lastDepositor);

    modifier depositQueueNotFull(){
        require(depositQueueLength <= DEPOSIT_QUEUE_MAX);
        _;
    }

    modifier operatorOnly(){
        require(msg.sender == operator);
        _;
    }

    constructor(
        // address _verifierAddr,
        address _mimcAddr,
        address _eddsaAddr
    ) ERC721Full("Snappframes", "SNP") public {
        // Verifier verifier = Verifier(_verifierAddr);
        mimc = MiMC(_mimcAddr);
        eddsa = EdDSA(_eddsaAddr);
    }

    // performs state transition
    function update() public operatorOnly{
        // TODO: wait for Geoff's verifier circuit
    }

    // creates accounts for people who deposit Ether
    // @dev _from and _to are index ranges for movie frames
    function deposit(uint _index, uint256[2] memory _eddsaPubKey) 
    public payable depositQueueNotFull{

        require(msg.value >= PRICE_PER_FRAME);

        depositQueueLength++;
        depositQueueAddresses[depositQueueLength - 1] = msg.sender;
        depositQueue[msg.sender] = _index;

        ecdsaToEddsa[msg.sender] = _eddsaPubKey;

        emit Deposit(msg.sender, _index);

    }

    // operator updates merkle tree with deposits
    function processDepositQueue() public operatorOnly{
        emit DepositsProcessed(
            depositQueueAddresses[0], 
            depositQueueAddresses[DEPOSIT_QUEUE_MAX]);
        depositQueueLength = 0;
    }


    // allows withdraw of ERC721 token to Ethereum address
    function withdraw(
        uint256 asset, 
        uint256[2] memory pubkey, //EdDSA pubKey_x and pubKey_y
        uint256[7] memory proof,
        uint256[7] memory proof_pos, 
        uint256 root
        // uint256 hashed_msg, //hash of msg.sender and leaf
        // uint256[2] memory R, //EdDSA signature field
        // uint256 s //EdDSA signature field
    ) public {
        uint256[2] memory eddsaPubKey = ecdsaToEddsa[msg.sender];
        require(eddsaPubKey[0] == pubkey[0] && eddsaPubKey[1] == pubkey[1]);

        // // verify EdDSA signature
        // require(EdDSA.Verify(pubkey, hashed_msg, R, s));  

        // // verify hashed msg sends leaf to msg.sender
        // uint256 leaf = mimc.MiMCpe7(pubkey[0], pubkey[1], asset);
        // require(verifyMerkleProof(leaf, proof, proof_pos, root))
        // require(mimc.MiMCpe7(msg.sender, leaf) == hashed_msg);

        // generate ERC721 token
        bytes32 tokenId = keccak256(abi.encodePacked(pubkey[0],pubkey[1]));
        _mint(msg.sender, bytes32ToUint256(tokenId));

        // send token to depositor on Ethereum
    }

    function verifyMerkleProof(
        uint256 _leafHash,
        uint256[7] memory _merkleProof,
        uint256[7] memory _merklePos,
        uint256 _root
    ) public view returns(bool){
        uint256[7] memory root;
        uint256 left = _leafHash - _merklePos[0]*(_leafHash - _merkleProof[0]);
        uint256 right = _merkleProof[0] - _merklePos[0]*(_merkleProof[0] - _leafHash);
        root[0] = mimc.MiMCpe7(left, right);
        for (uint i = 1; i < 3; i++) {
            left = root[i-1] - _merklePos[i]*(root[i-1] - _merkleProof[0]);
            right = _merkleProof[0] - _merklePos[i]*(_merkleProof[0] - root[i-1]);              
            root[i] = mimc.MiMCpe7(left, right);
            }
        return(root[2] == _root);
    }

    // helpers

    // https://ethereum.stackexchange.com/questions/6498/how-to-convert-a-uint256-type-integer-into-a-bytes32
    function bytes32ToUint256(bytes32 n) internal returns (uint256) {
        return uint256(n);
    }


}