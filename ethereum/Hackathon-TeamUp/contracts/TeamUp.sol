pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
 

contract TeamUp {
    
    //enum HackerRole {Leader, Designer, FrontEndDev, BackendDev}
    uint8 constant leader_role = 1;
    uint8 constant designer_role = 2;
    uint8 constant frontenddev_role = 3;
    uint8 constant backenddev_role = 4;
    string constant event_name = "ETHSF";

    struct Idea {
        bytes32 ideaId;
        address leader;
        string industry; 
        string tagline;
        

        bool isIdea; //for checking purpose in mapping
    }

    struct HackathonTeam {
        string hackathonName;
        bytes32 ideaId;

        address leader;
        address designer;
        address frontend_dev;
        address backend_dev;
        uint    partipants_votes;
        bool    isOfficial;
    }

    struct HackerIdeaVote {
        string hackathonName;
        address hacker;

        //as hacker ,i will vote 1st option for this idea with this role. 
        bytes32 ideaId;
        uint8   role;
        uint8   priority;
    }

    /******************************************************************************** */

    bytes32[] public IdeaCodes;
    mapping(bytes32 => Idea) public Ideas;
    mapping(bytes32 => HackathonTeam) public Teams;
    address[] voters;

    HackerIdeaVote[] public Votes;
    mapping(bytes32 => HackerIdeaVote[]) public IdeaVotes;     //idea hash --> votes.
    mapping(address => HackerIdeaVote[3]) public HackerVotes; //hacker--> votes.

    //**All events
    event IdeaPosted(bytes32 ideaId, address leader);
    event HackerVoteUpdated(address hacker, bytes32 ideaId, uint8 role, uint priority, string message);
    event HackerPicked(bytes32 ideaId, uint8 role, address hackerAddress);
    event TeamFormed(bytes32 ideaId);


    /******************************************************************************** */

    function getIdeaTeam(bytes32 ideaId) public view returns (address, address, address, address, uint, bool) {
        HackathonTeam team = Teams[ideaId];
        return (team.leader, team.designer, team.frontend_dev, team.backend_dev, team.partipants_votes, team.isOfficial);
    }
    
    function getVotesLength() public view returns (uint) {
        return Votes.length;
    }

    function getIdeaVotesCount(bytes32 ideaId) public view returns (uint) {
        return IdeaVotes[ideaId].length;
    }

    function getIdeaCodes() public view returns (bytes32[]) {
        return IdeaCodes;
    }

    function getIdeasLength() public view returns (uint) {
        return IdeaCodes.length;
    }

    function hasIdeaPosted(bytes32 ideaId) public view returns (bool) {
        for (uint i = 0; i < IdeaCodes.length; i++) {
            if (IdeaCodes[i] == ideaId) {
                return true; 
            }
        }

        return false;
    }

    /******************************************************************************** */

    /** Step 1 - post idea into blockchain and return a hash. 
     ** at the same time, team is initialized. 
     ** idea initiator is a default team leader
     */
    function postIdea(string industry, string tagline) external returns (bytes32) {
        //register idea
        bytes32 ideaId = keccak256(abi.encodePacked(industry, tagline));

        bool exists = hasIdeaPosted(ideaId);
        if (exists == true) {
            return ideaId;
        }

        Idea memory idea = Idea(ideaId, msg.sender, industry, tagline, false);
        //Ideas[Ideas.length] = idea;
        IdeaCodes.push(ideaId);
        Ideas[ideaId] = idea;

        //register hackathon team
        HackathonTeam memory team = HackathonTeam(event_name, ideaId, msg.sender, 0x0, 0x0, 0x0, 0, false);
        Teams[ideaId] = team;

        //create event
        emit IdeaPosted(ideaId, msg.sender);

        return ideaId;
    }

    /******************************************************************************** */

    /** Step 2 - hackers except leader to vote 3 priority cards for idea and role. 
     ** All votes are tracked. 
     ** Idea votes are tracked. 
     ** Hacker votes are tracked. 
     ** Every hacker can have at most 3 cards. They can also change decisions. 
     */
    function hackerToVote(bytes32 ideaId, uint8 role, uint priority) external {
        //cannot vote on leader role. 
        require(role != leader_role);
        require(priority >= 1 && priority <= 3);

        //always increment participants for that team and idea campaign. 
        HackathonTeam storage team = Teams[ideaId];
        //team.partipants_votes++;    --Bug, cannot be here. over count.             

        //look up for the same priority. 
        HackerIdeaVote storage oldVote = HackerVotes[msg.sender][priority-1];

        //new case for this priority
        if (oldVote.priority == 0) {
            HackerIdeaVote memory vote = HackerIdeaVote(event_name, msg.sender, ideaId, role, uint8(priority));
            
            Votes.push(vote);       
            IdeaVotes[ideaId].push(vote);           
            HackerVotes[msg.sender][priority-1] = vote;          
            team.partipants_votes++;

            emit HackerVoteUpdated(msg.sender, ideaId, role, priority, "new vote is added. ");
     
        } else {
            //existed, but either idea or role change, we will update. 
            if (oldVote.ideaId != ideaId) {
                oldVote.ideaId = ideaId;
                team.partipants_votes++;

                emit HackerVoteUpdated(msg.sender, ideaId, role, priority, "voting on different idea now. ");
       
            } else if (oldVote.role != role) {
                oldVote.role = role;
                team.partipants_votes++;
                emit HackerVoteUpdated(msg.sender, ideaId, role, priority, "role is changed for the saem vote. ");
            } else {
                emit HackerVoteUpdated(msg.sender, ideaId, role, priority, "no vote is updated. ");
            }
        }
    }

    /******************************************************************************** */

    /** Step 3 - Now, it is leader to pick hacker(s) out of voters. 
     ** Leader doesn't have to all decisions, but high suggest make progressive suggestion. 
     */
    function leaderToPick(bytes32 ideaId, uint8 role, address hackerAddress) external {
        //make sure caller is the leader for his team decison.
        HackathonTeam storage team = Teams[ideaId];
        address leaderAddress = team.leader;
        require(leaderAddress == msg.sender);

        if (role == designer_role) {
            team.designer = hackerAddress;
        } else if (role == frontenddev_role) {
            team.frontend_dev = hackerAddress;
        } else if (role == backenddev_role) {
            team.backend_dev = hackerAddress;
        } 

        emit HackerPicked(ideaId, role, hackerAddress);

        //always check whether all team members are picked or not. 
        if (team.designer != address(0x0) && team.frontend_dev != address(0x0) && team.backend_dev != address(0x0)) {
            team.isOfficial = true;
            emit TeamFormed(ideaId);
        }
    }

    /******************************************************************************** */

    /** Step 4 - The leader has the right to force to finalize a team even it is not fullly settled. 
     */
    function forceToFinalize(bytes32 ideaId) external {
        HackathonTeam storage team = Teams[ideaId];
        address leaderAddress = team.leader;
        //must be leader and team is not finalized beefore .
        require(team.isOfficial == false && leaderAddress == msg.sender);

        team.isOfficial = true;
        emit TeamFormed(ideaId);
    }
}