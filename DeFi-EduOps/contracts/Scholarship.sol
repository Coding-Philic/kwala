// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/// @title Scholarship Contract (basic)
// Note: This is a minimal, audit-needed example for testnets only.
// Functions separate approval and release for better control.

contract Scholarship {
    address public admin;
    uint public minGPA = 8; // example threshold (scale 0-10)
    event StudentRegistered(address indexed student, uint amount, uint gpa);
    event ScholarshipApproved(address indexed student, uint amount);
    event ScholarshipReleased(address indexed student, uint amount);

    struct Student {
        address wallet;
        uint gpa;      // store as integer, e.g., 85 for 8.5 if you choose that scale
        uint amount;   // in wei
        bool approved;
        bool paid;
    }

    mapping(address => Student) public students;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /// @notice Register or update a student's record (admin or offchain verifier should call)
    function registerStudent(address _wallet, uint _gpa, uint _amount) public onlyAdmin {
        students[_wallet] = Student(_wallet, _gpa, _amount, false, false);
        emit StudentRegistered(_wallet, _amount, _gpa);
    }

    /// @notice Approve a scholarship for a registered student (can be called by admin or automated workflow)
    function approveScholarship(address _wallet) public onlyAdmin {
        Student storage s = students[_wallet];
        require(s.wallet != address(0), "Not registered");
        require(!s.approved, "Already approved");
        s.approved = true;
        emit ScholarshipApproved(_wallet, s.amount);
    }

    /// @notice Release funds to an approved student
    function releaseScholarship(address payable _wallet) public onlyAdmin {
        Student storage s = students[_wallet];
        require(s.approved, "Not approved");
        require(!s.paid, "Already paid");
        uint amt = s.amount;
        require(address(this).balance >= amt, "Insufficient contract balance");
        s.paid = true;
        (bool ok, ) = _wallet.call{value: amt}("");
        require(ok, "Transfer failed");
        emit ScholarshipReleased(_wallet, amt);
    }

    /// @notice Allow contract to receive funds (fund the scholarship pool)
    receive() external payable {}
    fallback() external payable {}
}
