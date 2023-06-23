pragma solidity ^0.8.0;

contract IdeaContractv2 {
    struct Idea {
        string description;
        address proposer;
        string status; // 0: Pending, 1: Approved, 2: Rejected, 3: Duplicate
        uint256 cost;
        uint256 timestamp;
        mapping(address => bool) userLikes;
        uint256 likeCount;
    }

    mapping(uint => Idea) public ideas;
    uint public ideaCount;
    address public admin;
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can call this function.");
        _;
    }
    
    event IdeaProposed(uint256 indexed ideaId, string description, address indexed proposer, uint256 cost);
    event IdeaStatusUpdated(uint256 indexed ideaId, string newStatus);
    event IdeaCostUpdated(uint256 indexed ideaId, uint256 newCost);
    event IdeaLiked(uint256 indexed ideaId, address indexed liker);
    
    constructor() {
        admin = msg.sender;
    }
    
    function proposeIdea(string memory _description, uint256 _cost) external {
        require(bytes(_description).length > 0, "Description cannot be empty.");
        
        Idea storage newIdea = ideas[ideaCount];
        newIdea.description = _description;
        newIdea.proposer = msg.sender;
        newIdea.status = "pending";
        newIdea.cost = _cost;
        newIdea.timestamp = block.timestamp;
        newIdea.likeCount = 0;
        
        emit IdeaProposed(ideaCount, _description, msg.sender, _cost);
        
        ideaCount++;
    }
    
    function updateIdeaStatus(uint256 _ideaId, string memory _newStatus) external onlyAdmin {
        require(_ideaId < ideaCount, "Invalid idea ID.");
        require(keccak256(abi.encodePacked(_newStatus)) == keccak256(abi.encodePacked("approved")) || keccak256(abi.encodePacked(_newStatus)) == keccak256(abi.encodePacked("rejected")) || keccak256(abi.encodePacked(_newStatus)) == keccak256(abi.encodePacked("duplicate")), "Invalid status value."); // 1: Approved, 2: Rejected, 3: Duplicate
        
        ideas[_ideaId].status = _newStatus;
        
        emit IdeaStatusUpdated(_ideaId, _newStatus);
    }
    
    function updateIdeaCost(uint256 _ideaId, uint256 _newCost) external onlyAdmin {
        require(_ideaId < ideaCount, "Invalid idea ID.");
        
        ideas[_ideaId].cost = _newCost;
        
        emit IdeaCostUpdated(_ideaId, _newCost);
    }
    
    function likeIdea(uint _ideaId) external {
        require(_ideaId < ideaCount, "Invalid idea ID.");
        require(!ideas[_ideaId].userLikes[msg.sender], "User has already liked the idea");
        ideas[_ideaId].userLikes[msg.sender] = true;
        ideas[_ideaId].likeCount++;
        
        emit IdeaLiked(_ideaId, msg.sender);
    }
}