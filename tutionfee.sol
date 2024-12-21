// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TuitionFeeReimbursement {
    address public owner;
    uint public reimbursementFund;
    struct Student {
        address studentAddress;
        uint tuitionPaid;
        uint grades;
        bool isEligible;
        bool hasClaimed;
    }

    mapping(address => Student) public students;

    event FundAdded(address indexed from, uint amount);
    event TuitionPaid(address indexed student, uint amount);
    event ReimbursementClaimed(address indexed student, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyEligibleStudent(address _student) {
        require(students[_student].isEligible, "Student is not eligible for reimbursement");
        require(!students[_student].hasClaimed, "Reimbursement already claimed");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addFunds() public payable onlyOwner {
        reimbursementFund += msg.value;
        emit FundAdded(msg.sender, msg.value);
    }

    function registerStudent(address _student, uint _tuitionPaid, uint _grades) public onlyOwner {
        bool eligibility = _grades >= 70; // Minimum grade for eligibility
        students[_student] = Student({
            studentAddress: _student,
            tuitionPaid: _tuitionPaid,
            grades: _grades,
            isEligible: eligibility,
            hasClaimed: false
        });
    }

    function claimReimbursement() public onlyEligibleStudent(msg.sender) {
        uint reimbursementAmount = students[msg.sender].tuitionPaid;
        require(reimbursementFund >= reimbursementAmount, "Insufficient reimbursement fund");

        students[msg.sender].hasClaimed = true;
        reimbursementFund -= reimbursementAmount;
        payable(msg.sender).transfer(reimbursementAmount);

        emit ReimbursementClaimed(msg.sender, reimbursementAmount);
    }

    function getStudentDetails(address _student) public view returns (Student memory) {
        return students[_student];
    }
}
