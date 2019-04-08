pragma solidity >=0.5.0;

import "./dependencies/SafeMath.sol";
import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol';
import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Mintable.sol';

contract Verifier{

    function Verify() public {}

}

contract Snappframes is ERC721Full, ERC721Mintable {

    address operator = msg.sender;
    uint256 numFrames = 1000;
    uint pricePerFrame = 1000;
    uint8 depositQueueMax = 4;
    uint8 depositQueueLength = 0;
    address[4] depositQueueAddresses;
    mapping(address => uint[2]) depositQueue;

    event Deposit(address _depositor, uint _from, uint _to);
    event DepositsProcessed(address _firstDepositor, address _lastDepositor);

    modifier depositQueueNotFull(){
        require(depositQueueLength <= depositQueueMax);
        _;
    }

    modifier operatorOnly(){
        require(msg.sender == operator);
        _;
    }

    constructor(address _verifierAddr) ERC721Full("Snappframes", "SNP") public {
        Verifier verifier = Verifier(_verifierAddr);
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
        require(msg.value >= numFrames*pricePerFrame);

        depositQueueLength++;
        depositQueueAddresses[depositQueueLength - 1] = msg.sender;
        depositQueue[msg.sender] = [_from, _to];

        emit Deposit(msg.sender, _from, _to);

    }

    // operator updates merkle tree with deposits
    function processDepositQueue() public operatorOnly{
        emit DepositsProcessed(
            _depositQueueAddresses[0], 
            _depositQueueAddresses[depositQueueMax]);
        depositQueueLength = 0;
    }

    // allows withdraw of ERC721 token to Ethereum address
    function withdraw() public{
        // EdDSA verify a signed msgHash from token owner to Ethereum address

        // generate ERC721 token

        // send token to depositor on Ethereum
    }

}