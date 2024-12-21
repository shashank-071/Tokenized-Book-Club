// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenizedBookClub {
    string public constant name = "Tokenized Book Club";
    string public constant symbol = "BOOK";
    uint8 public constant decimals = 18; 
    uint256 public totalSupply;

    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event BookProposal(uint256 indexed bookId, string title, address proposer);
    event Vote(uint256 indexed bookId, address voter, uint8 score);

    struct Book {
        string title;
        address proposer;
        uint256 voteCount;
        uint8 totalScore;
        bool selected;
    }

    Book[] public books;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * 10**uint256(decimals);
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function proposeBook(string memory _title) public {
        books.push(Book({
            title: _title,
            proposer: msg.sender,
            voteCount: 0,
            totalScore: 0,
            selected: false
        }));
        emit BookProposal(books.length - 1, _title, msg.sender);
    }

    function vote(uint256 _bookId, uint8 _score) public {
        require(_bookId < books.length, "Invalid book ID");
        require(_score >= 1 && _score <= 5, "Score must be between 1 and 5");

        Book storage book = books[_bookId];
        book.voteCount++;
        book.totalScore += _score;
        emit Vote(_bookId, msg.sender, _score);
    }

    function selectBook(uint256 _bookId) public onlyOwner {
        require(_bookId < books.length, "Invalid book ID");
        books[_bookId].selected = true;
    }
}
