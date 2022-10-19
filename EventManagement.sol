// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract eventManagement
{
    struct Event{
    address payable organiser;
    string name;
    uint date;
    uint price;
    uint totalTicket;
    uint ticketAvailable; 
    }
    mapping(string => Event) public events;
    mapping(address => mapping(string => uint)) public tickets;//mapping to count the number of tickets purchased by person per event.
    function createEvent(string memory _name, uint _date, uint _price, uint _totalTicket) external 
    {
        require(_date>block.timestamp,"You can organise event in future");
        require(_totalTicket>0,"please available tickets");
        events[_name]= Event(payable(msg.sender),_name,_date,_price,_totalTicket,_totalTicket);
    } 
    modifier verification(string memory _name,uint _quantity)
    {
        require(msg.sender!= events[_name].organiser,"Organiser cannot buy tickets");
        require(events[_name].date!=0,"no such event");
        require(events[_name].date>=block.timestamp,"event closed");
        require(msg.value==(events[_name].price*_quantity),"please pay sufficent amount");
        require(events[_name].ticketAvailable >= _quantity,"not enough tickets");
        _; 
    }
    function buyTickets(string memory _name,uint  _quantity) public payable verification(_name,_quantity) 
    {
      Event storage _events = events[_name];
     _events.ticketAvailable -= _quantity;
     tickets[msg.sender][_name]+=_quantity;
     _events.organiser.transfer(msg.value);
    }
    function transferTickets(string memory _name,uint _quantity,address payable _to) external 
    {  
       require(msg.sender!= events[_name].organiser,"Organiser cannot transfer");
       require(events[_name].date!=0,"no such event");
       require(events[_name].date>=block.timestamp,"event closed");  
       require(tickets[msg.sender][_name]>=_quantity,"not have enough tickets");
       tickets[msg.sender][_name]-= _quantity;
       tickets[_to][_name]+= _quantity;
    }

}