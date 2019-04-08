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
    mapping(address => uint[2]) depositQueue;

    event Deposit(address _depositor, uint _from, uint _to);
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
    function deposit(uint _from, uint _to) public payable depositQueueNotFull{

        uint numFrames = _to - _from;
        require(numFrames > 0);
        require(msg.value >= numFrames*PRICE_PER_FRAME);

        depositQueueLength++;
        depositQueueAddresses[depositQueueLength - 1] = msg.sender;
        depositQueue[msg.sender] = [_from, _to];

        emit Deposit(msg.sender, _from, _to);

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
        uint256 hashed_msg, //hash of msg.sender and leaf
        uint256[2] memory R, //EdDSA signature field
        uint256 s //EdDSA signature field
    ) public {
        // verify EdDSA signature
        require(EdDSA.Verify(pubkey, hashed_msg, R, s)); 
        // return result; 

        // verify hashed msg sends leaf to msg.sender
        // uint leaf = mimc.MiMCpe7(pubkey[0], pubkey[1], asset);
        // require(mimc.MiMCpe7(msg.sender, leaf) == hashed_msg);

        // generate ERC721 token

        // send token to depositor on Ethereum
    }

}