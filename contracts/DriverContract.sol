// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./Escrow.sol";

error notReceivingRides(string);
error pendingRequest(string);
error noPendingRides(string);
error driverOnly(string);

contract DriverContract{
    enum States{
        inactive,
        ongoing,
        accepting
    }

    struct Ride{
        bool pending;
        bool completed;
        uint source;
        uint destination;
        //uint estimatedTripDuration; //from api
        //uint estimatedPayment; //from Price_fixing.sol
        address passenger;
        bool cancelled;
        // bytes32 id;
    }

    address payable public driver;
    States public state;
    Ride public curr_ride;
    Ride[] public rides;
    Escrow public curr_escrow;
    address public pendingPaymentEscrowAddress;

    modifier accepting(){
        if(state != States.accepting){
            revert notReceivingRides("currently driver is not receiving any rides.");
        }
        _;
    }

    constructor(address _driver) {
        driver = payable(_driver);
    }

    function setStateAccepting() public {
        state = States.accepting;
    }

    function setStateInactive() external {
        state = States.inactive;
    }

//estimatedTripDuration and estimatedPayment MUST BE ADDED LATER WHEN IMPLEMENTED

    function receiveRideRequest(uint _src,uint _dest,address _pass /*,bytes32 _id*/) public accepting{
        //check state using modifier
        if(curr_ride.pending){
            revert pendingRequest("Driver has a pending request!.");
        }

        curr_ride = Ride({
            pending : true,
            completed : false,
            source : _src,
            destination : _dest,
            passenger : _pass,
            cancelled : false
            //id : _id
        });

    }

    function acceptRideRequest() public payable accepting{
        //check state using modifier
        if(!curr_ride.pending){
            revert noPendingRides("Driver does not have any pending rides! Noting to accept.");
        }
        if(msg.sender != driver){
            revert driverOnly("Only the driver can accept his ride.");
        }
        require(msg.value >= 1000000000000000000, "Provide enough ETH!!");
        //deploy funded escrow contract
        curr_escrow = new Escrow{value:msg.value}(driver, curr_ride.passenger);
        //FIX THE CORRECT VALUE LATER. CURRENT VALUE (1 ETH) IS FOR TESTING PURPOSES ONLY !!!!!!!
    }

    function terminateOngoingRide() public {
        setStateAccepting();
        curr_ride.pending = false;
        curr_ride.completed = true;
        //receive payment from Escrow contract
        // (bool sent, ) = driver.call{value:address(curr_escrow).balance}(""); 
        //bool sent = driver.send(address(curr_escrow).balance); 
        // if(!sent){
        //     pendingPaymentEscrowAddress = address(curr_escrow);
        // }
        curr_escrow.disperse();
        rides.push(curr_ride);
        resetCurrentRide();
    }

//might be required later for assigning ride id. Current plan is to pass to from api
    function generateId() private view returns (bytes32) {
        bytes32 blockHash = blockhash(block.number - 1); // Get the block hash of the previous block
        bytes32 id = keccak256(abi.encodePacked(blockHash, block.timestamp, driver));  
        return id;
    }

    function fetchCurrentRideDetails() public view returns (Ride memory) {
        return curr_ride;
    }

    function resetCurrentRide() public {
        curr_ride.pending = false;
        curr_ride.completed = false;
        curr_ride.source = 0;
        curr_ride.destination = 0;
        curr_ride.passenger = address(0);
    }
    function getDriverBalance() public view returns(uint){
        return address(driver).balance;
    }

    function getEscrowBalance() public view returns(uint){
        return address(curr_escrow).balance;
    }
}