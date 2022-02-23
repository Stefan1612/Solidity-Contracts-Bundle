// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//import "./IERC20.sol";
interface IERC20 {
    function totalSupply() external view returns (uint256); 
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


//utilizing native ERC20 token
contract CrowdFund {

    // ProjectID => userAddress => ammount pledged
    mapping(uint => mapping(address => uint)) public userPledgedToProject;
    mapping(uint => Project) public IdToProject;

    uint projectID = 0;

    struct Project {    
        string Description;
        uint ID;
        address creator;
        uint goal;
        uint32 startAt;
        uint32 endAt;
        uint pledged;
    }

    IERC20 public immutable token;
    
    event ProjectLaunched(
        string description,
        uint ID,
        address indexed creator,
        uint indexed goal,
        uint32 startAt,
        uint32 indexed endAt,
        uint pledged
    );

    event ProjectDeleted(
        uint indexed ID,
        address indexed creator
    );

    event PledgedToProject(
        address indexed pledger,
        uint indexed amount,
        uint indexed ID
    );

    constructor(address _token) {
        token = IERC20(_token);
    }

    //uint32 is able to display time up to 100 years
    function launch(uint _goal, uint32 _startAt, uint32 _endAt, string memory _description) external {
        require(_startAt >= block.timestamp, "It needs to be some time in the future");
        require(_endAt > _startAt, "starting Time < ending time of crowd fund");
        require(_endAt <= block.timestamp + 90 days, "Maximum running time = 90 days");

        projectID += 1;

        IdToProject[projectID] = Project(
            _description,
            projectID,
            msg.sender,
            _goal,
            _startAt,
            _endAt,
            0
        );
        emit ProjectLaunched(_description, projectID, msg.sender, _goal, _startAt, _endAt, 0);
    }

    function cancel(uint _id) external {
        //reassigning to memory variable once to save a bit of gas
        Project memory project = IdToProject[_id];
        require(msg.sender == project.creator, "Only the creator can cancel the project");
        require(block.timestamp < project.startAt, "started");
        delete IdToProject[_id];
        emit ProjectDeleted(_id, msg.sender);
    }

    function pledge(uint _id, uint _amount) external payable {
        //declaring project as project due to updating the state
        Project storage project = IdToProject[_id];
        require(block.timestamp >= project.startAt, "Project hasn't started yet");
        require(block.timestamp <= project.endAt, "Project ended");
        
        project.pledged += _amount;
        userPledgedToProject[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);

        emit PledgedToProject(msg.sender, _amount, _id);
    }
 }
