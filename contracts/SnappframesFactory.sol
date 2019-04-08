pragma solidity ^0.5.4;

// ----------------------------------------------------------------------------
// Borrowed from BokkyPooBah's Fixed Supply Token 👊 + Factory v1.10
// https://github.com/bokkypoobah/FixedSupplyTokenFactory
//
//
//
// Snappframes Factory Contract
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2019. The MIT Licence.
// ----------------------------------------------------------------------------


import "./dependancies/SafeMath.sol";
import "./dependancies/Owned.sol";

// import "./Snappframes.sol";
// import "../circuits/verifier.sol";


contract MiMC{

    function MiMCpe7(uint,uint) public pure returns (uint) {}

}

contract EdDSA{

    function Verify( uint256[2] memory, uint256, uint256[2] memory, uint256 )
        public view returns (bool) {}

}



contract Snappframes is Owned, EdDSA, MiMC  {
    using SafeMath for uint;
    using SafeMath for uint256;

    string public symbol;
    string public name;
    uint256 public totalSupply;
    uint256 public dataHash;
    uint256 public stateHash;
    address public operator;
    uint256 public pricePerFrame;

    address[4] depositQueueAddresses;
    mapping(address => uint) depositQueue;
    mapping(address => uint256[2]) public ecdsaToEddsa;

    uint8 DEPOSIT_QUEUE_MAX = 4;
    uint8 depositQueueLength = 0;
    uint public TREE_DEPTH = 6;
    uint PRICE_PER_FRAME = 1000;


    // Verifier verifier;
    MiMC mimc;
    EdDSA eddsa;

    event Deposit(address _depositor, uint _index);
    event DepositsProcessed(address _firstDepositor, address _lastDepositor);


    function init(address tokenOwner, string memory _symbol, string memory _name, uint256 _totalSupply, uint256 _dataHash, uint256 _stateHash, address _mimcAddr, address _eddsaAddr)  public {
        super.init(tokenOwner);
        symbol = _symbol;
        name = _name;
        totalSupply = _totalSupply;
        dataHash = _dataHash;
        stateHash = _stateHash;
        mimc = MiMC(_mimcAddr);
        eddsa = EdDSA(_eddsaAddr);
    }


    // performs state transition
    function update() public onlyOwner {
        // TODO: wait for Geoff's verifier circuit
    }

    // creates accounts for people who deposit Ether
    // @dev _from and _to are index ranges for movie frames
    function deposit(uint256 _index, uint256[2] memory _eddsaPubKey)
    public payable {
        require(depositQueueLength <= DEPOSIT_QUEUE_MAX);
        require(msg.value >= PRICE_PER_FRAME);

        depositQueueLength++;
        depositQueueAddresses[depositQueueLength - 1] = msg.sender;
        depositQueue[msg.sender] = _index;

        ecdsaToEddsa[msg.sender] = _eddsaPubKey;

        emit Deposit(msg.sender, _index);

    }

    // operator updates merkle tree with deposits
    function processDepositQueue() public onlyOwner {
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
    ) public view {
        uint256[2] memory eddsaPubKey = ecdsaToEddsa[msg.sender];
        require(eddsaPubKey[0] == pubkey[0] && eddsaPubKey[1] == pubkey[1]);

        // // verify EdDSA signature
        // require(EdDSA.Verify(pubkey, hashed_msg, R, s));

        // verify hashed msg sends leaf to msg.sender
        uint256 leaf = mimc.MiMCpe7(mimc.MiMCpe7(pubkey[0], pubkey[1]), asset);
        require(verifyMerkleProof(leaf, proof, proof_pos, root));
        // require(mimc.MiMCpe7(msg.sender, leaf) == hashed_msg);

        // generate ERC721 token
        // bytes32 tokenId = keccak256(abi.encodePacked(pubkey[0],pubkey[1]));
        //_mint(msg.sender, bytes32ToUint256(tokenId));

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
    function bytes32ToUint256(bytes32 n) internal pure returns (uint256) {
        return uint256(n);
    }

}





// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
contract SnappframesFactory is Owned  {
    using SafeMath for uint;

    address public newAddress;
    uint public minimumFee = 0.1 ether;
    mapping(address => bool) public isChild;
    address[] public children;

    event FactoryDeprecated(address _newAddress);
    event MinimumFeeUpdated(uint oldFee, uint newFee);
    event TokenDeployed(address indexed owner, address indexed token, string symbol, string name, uint256 totalSupply, uint256 dataHash, uint256 stateHash);

    constructor () public {
        super.init(msg.sender);
    }
    function numberOfChildren() public view returns (uint) {
        return children.length;
    }
    function deprecateFactory(address _newAddress) public onlyOwner {
        require(newAddress == address(0));
        emit FactoryDeprecated(_newAddress);
        newAddress = _newAddress;
    }
    function setMinimumFee(uint _minimumFee) public onlyOwner  {
        emit MinimumFeeUpdated(minimumFee, _minimumFee);
        minimumFee = _minimumFee;
    }
    function deployTokenContract(string memory symbol, string memory name, uint256 totalSupply, uint256 dataHash, uint256 stateHash,address mimcAddr, address eddsaAddr) public payable returns (Snappframes token)  {
        require(msg.value >= minimumFee);
        require(totalSupply > 0);
        token = new Snappframes();
        token.init(msg.sender, symbol, name, totalSupply, dataHash, stateHash, mimcAddr, eddsaAddr );

        isChild[address(token)] = true;
        children.push(address(token));
        if (msg.value > 0) {
            owner.transfer(msg.value);
        }
        emit TokenDeployed(owner, address(token), symbol, name, totalSupply, dataHash, stateHash);

    }
    function () external payable {
        revert();
    }
}
