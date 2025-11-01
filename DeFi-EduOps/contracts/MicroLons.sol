// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title Simple MicroLoan Contract (testnet prototype)
// NOTE: This is a simplified version for POC/demo. Production requires interest math, loan pools, collateral, and security checks.

contract MicroLoan {
    address public admin;
    uint public loanCounter;

    struct Loan {
        uint id;
        address borrower;
        uint principal; // wei
        uint interest;  // wei (simple fixed interest amount for POC)
        uint dueDate;   // epoch seconds
        bool repaid;
    }

    mapping(uint => Loan) public loans;
    mapping(address => uint[]) public borrowerLoans;

    event LoanCreated(uint indexed id, address indexed borrower, uint principal, uint interest, uint dueDate);
    event LoanRepaid(uint indexed id, address indexed borrower, uint amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    constructor() {
        admin = msg.sender;
        loanCounter = 0;
    }

    /// @notice Admin funds the contract to create liquidity pool
    receive() external payable {}

    /// @notice Create a loan for borrower. For POC admin creates loan and transfers funds.
    function createLoan(address payable _borrower, uint _principal, uint _interest, uint _durationDays) public onlyAdmin {
        require(address(this).balance >= _principal, "Insufficient pool balance");
        loanCounter += 1;
        uint due = block.timestamp + (_durationDays * 1 days);
        loans[loanCounter] = Loan(loanCounter, _borrower, _principal, _interest, due, false);
        borrowerLoans[_borrower].push(loanCounter);

        // transfer principal
        (bool ok, ) = _borrower.call{value: _principal}("");
        require(ok, "Transfer failed");

        emit LoanCreated(loanCounter, _borrower, _principal, _interest, due);
    }

    /// @notice Repay loan: borrower sends principal + interest
    function repayLoan(uint _loanId) public payable {
        Loan storage l = loans[_loanId];
        require(l.id != 0, "Loan not exist");
        require(!l.repaid, "Already repaid");
        require(msg.value >= (l.principal + l.interest), "Insufficient repayment");
        l.repaid = true;
        emit LoanRepaid(_loanId, msg.sender, msg.value);
        // funds remain in contract (admin can withdraw later)
    }

    /// @notice Admin can withdraw contract funds (for demo only)
    function adminWithdraw(uint _amount) public onlyAdmin {
        require(address(this).balance >= _amount, "Insufficient balance");
        (bool ok, ) = payable(admin).call{value: _amount}("");
        require(ok, "Withdraw failed");
    }
}
