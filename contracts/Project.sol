// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0 < 0.9.0 ;


contract Project {

    enum State {
        Fundraising,
        Expired,
        Successful
    }

    struct WithdrawRequest {
        string description;
        uint256 amount;
        uint256 noOfVotes;
        mapping(address => bool) voters;
        bool isCompleted;
        address payable recipient;
    }

    address payable public creator;
    uint256 public minimumContribution;
    uint256 public deadline;
    uint256 public targetContribution;
    uint256 public raisedAmount;
    uint256 public noOfContributors;
    string public projectTitle;
    string public projectDes;
    State public state = State.Fundraising;

    mapping(address => uint256) public contributors;
    mapping(uint256 => WithdrawRequest) public withdrawRequests;

    uint256 public numOfWithdrawRequests = 0;

    modifier isCreator() {
        require(msg.sender == creator, 'You dont have access to perform this operation!');
        _;
    }

    modifier validateExpiry(State _state) {
        require(state == _state, 'Invalid state');
        require(block.timestamp < deadline, 'Deadline has passed!');
        _;
    }

    modifier validateState(State _requiredState) {
        require(state == _requiredState, 'Invalid state');
        _;
    }

    event FundingReceived(address contributor, uint256 amount, uint256 currentTotal);
    event WithdrawRequestCreated(uint256 requestId, string description, uint256 amount, uint256 noOfVotes, bool isCompleted, address recipient);
    event WithdrawVote(address voter, uint256 totalVote);
    event AmountWithdrawSuccessful(uint256 requestId, string description, uint256 amount, uint256 noOfVotes, bool isCompleted, address recipient);

    constructor(
        address _creator,
        uint256 _minimumContribution,
        uint256 _deadline,
        uint256 _targetContribution,
        string memory _projectTitle,
        string memory _projectDes
    ) {
        creator = payable(_creator);
        minimumContribution = _minimumContribution;
        deadline = _deadline;
        targetContribution = _targetContribution;
        projectTitle = _projectTitle;
        projectDes = _projectDes;
    }

    function contribute(address _contributor) public validateExpiry(State.Fundraising) payable {
        require(msg.value >= minimumContribution, 'Contribution amount is too low!');
        require(contributors[_contributor] == 0, 'Contributor has already contributed!');

        noOfContributors++;
        contributors[_contributor] += msg.value;
        raisedAmount += msg.value;

        emit FundingReceived(_contributor, msg.value, raisedAmount);
        checkFundingCompleteOrExpire();
    }

    function checkFundingCompleteOrExpire() internal {
        if (raisedAmount >= targetContribution) {
            state = State.Successful;
        } else if (block.timestamp > deadline) {
            state = State.Expired;
        }
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function requestRefund() public validateExpiry(State.Expired) returns (bool) {
        require(contributors[msg.sender] > 0, 'You dont have any contributed amount!');
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
        return true;
    }

    function createWithdrawRequest(string memory _description, uint256 _amount, address payable _recipient) public isCreator() validateState(State.Successful) {
        WithdrawRequest storage newRequest = withdrawRequests[numOfWithdrawRequests];
        numOfWithdrawRequests++;

        newRequest.description = _description;
        newRequest.amount = _amount;
        newRequest.noOfVotes = 0;
        newRequest.isCompleted = false;
        newRequest.recipient = _recipient;

        emit WithdrawRequestCreated(numOfWithdrawRequests, _description, _amount, 0, false, _recipient);
    }

    function voteWithdrawRequest(uint256 _requestId) public {
        require(contributors[msg.sender] > 0, 'Only contributor can vote!');
        WithdrawRequest storage requestDetails = withdrawRequests[_requestId];
        require(!requestDetails.voters[msg.sender], 'You already voted!');
        requestDetails.voters[msg.sender] = true;
        requestDetails.noOfVotes += 1;
        emit WithdrawVote(msg.sender, requestDetails.noOfVotes);
    }

    function withdrawRequestedAmount(uint256 _requestId) isCreator() validateState(State.Successful) public {
        WithdrawRequest storage requestDetails = withdrawRequests[_requestId];
        require(!requestDetails.isCompleted, 'Request already completed');
        require(requestDetails.noOfVotes >= noOfContributors / 2, 'At least 50% contributor need to vote for this request');
        requestDetails.recipient.transfer(requestDetails.amount);
        requestDetails.isCompleted = true;

        emit AmountWithdrawSuccessful(
            _requestId,
            requestDetails.description,
            requestDetails.amount,
            requestDetails.noOfVotes,
            true,
            requestDetails.recipient
        );
    }

    function getProjectDetails() public view returns (
        address payable projectStarter,
        uint256 minContribution,
        uint256 projectDeadline,
        uint256 goalAmount,
        uint256 completedTime,
        uint256 currentAmount,
        string memory title,
        string memory desc,
        State currentState,
        uint256 balance
    ) {
        projectStarter = creator;
        minContribution = minimumContribution;
        projectDeadline = deadline;
        goalAmount = targetContribution;
        completedTime = block.timestamp;
        currentAmount = raisedAmount;
        title = projectTitle;
        desc = projectDes;
        currentState = state;
        balance = address(this).balance;
    }
}
