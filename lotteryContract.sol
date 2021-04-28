//SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract Lottery {
    address payable[] public players;
    address public manager;
    
    constructor(){
        manager = msg.sender;
    }
    
    modifier adminOnly (){
        require(msg.sender == manager, 'The caller is not the admin');
        _;
    }
    
    modifier buyTicket {
        require(msg.value == 0.1 ether, 'For you to be able to enter the game you need to transfer 0.1 ETH');
        _;
    }
    
    modifier atLeast3Players{
        require(players.length >= 3);
        _;
    }
    
    modifier contractHasFunds{
        require(getBalance() > 0, 'The contract has no Funds');
        _;
    }
    
    modifier blockManager{
        require(msg.sender != manager, 'Manager cannot participate in the game!');
        _;
    }
    
    receive() external payable buyTicket blockManager{
        players.push(payable (msg.sender));
    }
    
    function getBalance() public view adminOnly returns (uint){
        return address(this).balance;
    }
    
    function randomNumber() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }
    
    function pickWinner() public  adminOnly atLeast3Players contractHasFunds {
        
        
        uint r = randomNumber();
        address payable winner;
        
        uint randomIndex = r % players.length;
        winner = players[randomIndex];
        winner.transfer(getBalance());
        players = new address payable[](0); //reset the lottery
    }
}