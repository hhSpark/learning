pragma solidity ^0.4.23;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TeamUp.sol";

contract TestTeamUp {
    TeamUp teamup = TeamUp(DeployedAddresses.TeamUp());

    function testPostIdea() public {
        //this contract will adopt pet id 8
        bytes32 ideaId = teamup.postIdea("cool industry", "cool idea");
       
        uint ideaCount = teamup.getIdeasLength();
        bytes32[] memory ideaCodes = teamup.getIdeaCodes();

        uint expected = 1;
        Assert.equal(ideaCount, expected, "testPostIdea() success. ");
        
    }

    function testhasIdeaPosted() public {
         bytes32 ideaId = teamup.postIdea("cool industry", "cool idea");
        bool exist = teamup.hasIdeaPosted(ideaId);
        Assert.equal(exist, true, "testhasIdeaPosted() success. ");

    }

    function testHackerToVote() public  {
        bytes32 ideaId_1 = teamup.postIdea("cool industry1", "cool idea");
        bytes32 ideaId_2 = teamup.postIdea("cool industry2", "cool idea");
        bytes32 ideaId_3 = teamup.postIdea("cool industry3", "cool idea");
        bytes32 ideaId_4 = teamup.postIdea("cool industry4", "cool idea");

        Assert.notEqual(ideaId_1, ideaId_2, "Id should be different.");
       //test bad prarams
        teamup.hackerToVote(ideaId_1, 2, 1);
        teamup.hackerToVote(ideaId_2, 2, 2);
        teamup.hackerToVote(ideaId_4, 2, 3);
        
        uint size = teamup.getVotesLength();
        Assert.equal(size, 3, "Total votes should be 3");
        
        uint count = teamup.getIdeaVotesCount(ideaId_2);
        Assert.equal(count, 1, "Role voters should be 1");

    }

    function testLeaderToPick() public  {
        bytes32 ideaId_1 = teamup.postIdea("cool industry1", "cool idea");

        teamup.leaderToPick(ideaId_1, 2, msg.sender);

    }

    function testforceToFinalize() public {
        bytes32 ideaId_1 = teamup.postIdea("cool industry1", "cool idea");

        teamup.forceToFinalize(ideaId_1);
        //Assert.equal(count, 1, "Role voters should be 1");
    }
    
    function testgetIdeaTeam() public {
        bytes32 ideaId_1 = teamup.postIdea("cool industry1", "cool idea");
        teamup.getIdeaTeam(ideaId_1);
    }
}