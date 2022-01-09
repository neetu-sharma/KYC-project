    
pragma solidity ^0.5.9;

contract admininterface {

    address public admin;

    constructor() public {
        admin = msg.sender;
    }

    // We define the modifiers used as part of our functions here.
    //modifier isVotingOpen {
        //require(isVoting == true, "Voting process is not open.");
      //  _;
    //}
    modifier verifyadmin(address){
        require(admin == msg.sender, "Incorrect admin control accessed");
        _;
    }
}