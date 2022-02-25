// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract multiSigWallet {

    //[]address private owner;
    uint public numberOfMinApprove;

    // txId => address => did she/he approve the Tx?
    mapping(uint => mapping(address => bool)) public approvalForTxFromAddress;
    mapping(address => bool) public isOwner;
    Transaction[] private transactionArray;

    event Deposit(
        address indexed sender,
        uint amount
    );

    event Submit(
        uint indexed txId
    );

    event Approve(
        address indexed owner, 
        uint indexed txId
    );

    event Revoke(
        address indexed owner,
        uint indexed txId
    );

    event Execute(
        uint indexed txId
    );

    struct Transaction{
        uint value;
        address to;
        bytes data;
        bool executed;
    }

    modifier onlyOwner(){
        require(isOwner[msg.sender], "Message sender is not an owner");
        _;
    }

   


    constructor(address[] memory _owner, uint _numberOfMinApprove){
        require(_numberOfMinApprove > 0 && _numberOfMinApprove <= _owner.length, "NumberOfMinApprove must be <= number of owners and larger than 0");

        for(uint i = 0; i < _owner.length; i++){
            require(!isOwner[_owner[i]], "Address is already an owner");
            require(_owner[i] != address(0), "Address 0 cannot be an owner");
            isOwner[_owner[i]] = true;
            //owner.push(_owner[i]);
        }  
        numberOfMinApprove = _numberOfMinApprove;
    }


    function createTxRequest(uint _value, address _to, bytes calldata _data)public onlyOwner{
        transactionArray.push(Transaction(
             _value,
            _to,
            _data,
            false
            )   
        );
        emit Submit(transactionArray.length - 1);
    }

    function approveTxRequest(uint _txId) external onlyOwner {
        require(_txId > 0, "Transaction ID doesn't exist");
        require(approvalForTxFromAddress[_txId - 1][msg.sender] == false, "You already approved this transaction");
        require(_txId > transactionArray.length, "Transaction doesn't exist");
        require(transactionArray[_txId - 1].executed == false, "Transaction already went through");

        approvalForTxFromAddress[_txId - 1][msg.sender] = true;

        emit Approve(msg.sender, _txId);
    }

    function revokeAprobalForTX(uint _txId) external onlyOwner {
        require(_txId > 0, "Transaction ID doesn't exist");
        require(approvalForTxFromAddress[_txId - 1][msg.sender] == false, "You already approved this transaction");
        require(_txId > transactionArray.length, "Transaction doesn't exist");
        require(transactionArray[_txId - 1].executed == false, "Transaction already went through");
    }

    receive() payable external {
        emit Deposit(msg.sender, msg.value);
    }
}
