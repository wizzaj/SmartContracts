// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract lottery
{
    address public manager ;
    address payable[] public participants;
    address payable wnner;
    constructor ()
    {
        manager=msg.sender;
    }
    receive() external payable 
    {
        require(msg.value >= 2 ether,"pay correct amount");
        participants.push(payable(msg.sender));
    }
    function getBalance() public view returns(uint)
    {
        require(msg.sender==manager);
        return address(this).balance;
    }
    function checkwinner() public view returns(address)
    {
        return wnner;
    }
    function pickRandomVariable() private view returns(uint)
    {
           return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,participants.length)));      
    }
    function pickWinner() external 
    {
        require(msg.sender==manager);
         uint index=pickRandomVariable();
        index = index % participants.length;
        wnner= participants[index];
         participants= new  address payable[](0);
        (bool sent,)=wnner.call{value:address(this).balance}("");
        require(sent,"transfer failed");
       
    }
}