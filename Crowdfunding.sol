// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
    struct project
    {
        string project_name;
        uint targetMoney;
        uint startingDate;
        uint completionDate;
    }
    struct Request
    {
        string description;
        address payable to;
        uint totalAmount;
        bool completed;
        uint approvalCount;
        mapping (address => bool) votingPhase;
    } 
   
contract Contributer
{
    address public manager;
    uint public min_contribution;
    uint public no_of_contributor;
    uint public raisedAmount;
    mapping(string => mapping(address=>uint))  public  contributer ;
    mapping(string => project) public projects;
    mapping (string => mapping(string => Request)) public requests;   
    constructor(uint _contribution)
    {
        manager=msg.sender;
        min_contribution=_contribution;
    }
    modifier Ownership
    {
        require(msg.sender==manager);
        _;
    }
  function fundProject(string memory _project_name)external payable
    {
        require(block.timestamp > projects[_project_name].startingDate,"Project is not live please wait");
        require(msg.value > min_contribution,"not enough to contribute");
        require(block.timestamp < projects[_project_name].completionDate,"Project ended");
        require(address(this).balance == projects[_project_name].targetMoney,"target achieved");
        if(contributer[_project_name][msg.sender]==0)
        {
            no_of_contributor++;
        }
        contributer[_project_name][msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }
    function refund(string memory _project_name) external 
    {
        require(block.timestamp>projects[_project_name].completionDate,"please wait deadline not reached");
        require(raisedAmount < projects[_project_name].targetMoney,"not eligble for refund");
        contributer[_project_name][msg.sender]=0;
        payable(msg.sender).transfer(contributer[_project_name][msg.sender]);
    }
   
    function approveRequest(string memory _project_name,string memory _description) public
    {
        require(contributer[_project_name][msg.sender] != 0,"you are not a contributer");
        require(keccak256(abi.encodePacked(requests[_project_name][_description].description)) == keccak256(abi.encodePacked(_description)),"sorry check the request");
        require(requests[_project_name][_description].votingPhase[msg.sender] == false ,"you have already voted");
        requests[_project_name][_description].approvalCount++; // for request vote counter increased.
        requests[_project_name][_description].votingPhase[msg.sender]=true; // voting recorded.
    }
    function transferFunds(string memory projectname , string memory description) public Ownership
    {
        require(requests[projectname] [description].completed == true,"request already reviwed");
        require(requests[projectname][description].approvalCount >  (no_of_contributor) / 2,"request not approved");
        requests[projectname] [description].completed =true;
        requests[projectname][description].to.transfer( requests[projectname][description].totalAmount);
    }
    function createProject(string memory _project_name,uint _targetMoney,uint _startingDate,uint _completionDate) external Ownership
    {
        projects[_project_name]=project(_project_name,_targetMoney,_startingDate,_completionDate);
    }
     function  createRequest(string memory _projectname,string memory _description,uint _amount,address _to) external Ownership
    {
        Request storage newrequest = requests[_projectname][_description];
        newrequest.description=_description;
        newrequest.to=payable(_to);
        newrequest.totalAmount=_amount;
        newrequest.completed=false;
        newrequest.approvalCount=0;
    }
    function checkbalance() external view Ownership returns (uint)
    {
        return address(this).balance;
    }


}