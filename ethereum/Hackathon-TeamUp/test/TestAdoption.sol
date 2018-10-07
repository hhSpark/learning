pragma solidity ^0.4.23;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Adoption.sol";

contract TestAdoption {
    Adoption adoption = Adoption(DeployedAddresses.Adoption());

    function testUserCanAdoptPet() public {
        //this contract will adopt pet id 8
        uint returnId = adoption.adopt(8);

        uint expected = 8;
        Assert.equal(returnId, expected, "Adoption of PetId should be recorded. ");
           
    }

    function testGetAdopterAddressByPetId() public {
        //expect owner of this contracts
        address expected = this;

        address adopter = adoption.adopters(8);

        Assert.equal(adopter,expected,"owners of pet Id 8 should be recorded");
    }

    function testGetAdopters() public {
        address expected = this;

        //Store adopters in memory rather than contract's storage
        address[16] memory adopters = adoption.getAdopters();

        Assert.equal(adopters[8], expected, "Owne of pet Id should be retrieved");
    }
}
