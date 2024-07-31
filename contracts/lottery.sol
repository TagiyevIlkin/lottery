// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract Lottery{
    // Declare address of players
    address payable [] public players;
    // Declare address of manager
    address  manager;

    // Initialize the manager address by constructor
    constructor() {
        manager=msg.sender;
    }


    receive() external payable {
        // Require the value is  0.1 ether
        require(msg.value==0.1 ether,"More or less than 0.1 ether is not allowed");
        // Do not let manager participate in the lottery
        require(msg.sender!=manager,"Manager cannot participate in the lottery");
        // Convert the address to payable adress and add to dynamic array
        players.push(payable(msg.sender));
    }
     
    // getBalance returns the current balance of the contract
    function getBalance()public view returns(uint){
        // Require that only manager can see the balance
        require(msg.sender==manager,"Only manager can call see the balance");
        return address(this).balance;
    }


    // random return the random number
    // Note: It is not truly random number since outcome is deterministic 
    // Note: In real program we should use oracle to generate and proof random number 
    function random()public  view  returns (uint){
       
         return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,players.length)));
    }

    // pickWinner picks the winner and transfers the balance of the contract to the winner
    function pickWinner()public{
        // Require that only manager can call the function
        require(msg.sender==manager,"Only manager can call the function");
        // Require that there should be at least 3 players to pick the winner
        require(players.length>=3,"There should be at least 3 players to pick the winner");
        uint r =random();
        address payable winner;
        // Get the index of winner by mod operator
        uint index =r % players.length;
        winner= players[index];
        // Calculate the manager fee and winner prize
        // Manager fee is 10%
        uint managerFee = (getBalance() * 10 ) / 100; 
        // Winner prize is 90%
        uint winnerPrize = (getBalance() * 90 ) / 100;     
        
        // Transfer 90% of contract's balance to the winner
        winner.transfer(winnerPrize);
        
        // Transfer 10% of contract's balance to the manager
        payable(manager).transfer(managerFee);
        
        // Reset the lottery
        players=new address payable [](0);
    }

}