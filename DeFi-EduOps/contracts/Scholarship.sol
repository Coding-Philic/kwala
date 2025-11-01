// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
 * MicroLoan.sol
 * Simple POC for micro-loans. Admin funds pool, admin issues loans, borrowers repay.
 * NOT production-ready: interest math, collateral, and security checks are simplified.
 */

contract MicroLoan {
    address public admin;
    uint public loanCounter;

    struct Loan {
        uint id;
        address borrower;
        uint principal;
        uint interest; // fixed amount in wei for POC
        uint dueDate;
        bool repaid;
    }

    mapping(uint => Loan) public loans;
    mapping(address => uint[]) public borrowerLoans;

    event LoanCreated(uint indexed id, address indexed borrower, uint principal, uint interest, uint dueDate);
    event LoanRepaid(uint indexed id, address indexed borrower, uint amount);
    event FundsDeposited(address indexed from, uint amount);
    event AdminWithdraw(address indexed to, uint amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    constructor() {
        admin = msg.sender;
        loanCounter = 0;
    }

    receive() external payable {
        emit FundsDeposited(msg.sender, msg.value);
    }

    // Admin creates a loan and transfers principal to borrower
    function createLoan(address payable _borrower, uint _principal, uint _interest, uint _durationDays) public onlyAdmin {
        require(address(this).balance >= _principal, "Insufficient pool balance");
        loanCounter += 1;
        uint due = block.timestamp + (_durationDays * 1 days);
        loans[loanCounter] = Loan(loanCounter, _borrower, _principal, _interest, due, false);
        borrowerLoans[_borrower].push(loanCounter);
        (bool ok, ) = _borrower.call{value: _principal}("");
        require(ok, "Transfer failed");
        emit LoanCreated(loanCounter, _borrower, _principal, _interest, due);
    }

    // Borrower repays loan (principal + interest)
    function repayLoan(uint _loanId) public payable {
        Loan storage l = loans[_loanId];
        require(l.id != 0, "Loan not exist");
        require(!l.repaid, "Already repaid");
        uint dueAmount = l.principal + l.interest;
        require(msg.value >= dueAmount, "Insufficient repayment");
        l.repaid = true;
        emit LoanRepaid(_loanId, msg.sender, msg.value);
        // Funds stay in contract; admin may withdraw later
    }

    // Admin withdraws (for demo)
    function adminWithdraw(uint _amount) public onlyAdmin {
        require(address(this).balance >= _amount, "Insufficient balance");
        (bool ok, ) = payable(admin).call{value: _amount}("");
        require(ok, "Withdraw failed");
        emit AdminWithdraw(admin, _amount);
    }

    // Get borrower loans
    function getBorrowerLoans(address _borrower) public view returns (uint[] memory) {
        return borrowerLoans[_borrower];
    }
}
