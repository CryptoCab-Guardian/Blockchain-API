// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Escrow.sol";
import "./Main.sol";

error escrowFundingError(string Description, bool status);
error notEnoughETH(string Description, uint256 ethSent);

contract User {
    enum States {
        idle,
        pending,
        active
    }

    struct Ride {
        uint256 id;
        address passenger;
        address driver;
        uint256 pickupLocation;
        uint256 destination;
        uint256 fare;
        bool isBooked;
        address payable escrowContract;
        bool confirmedByPassenger;
        bool confirmedByDriver;
        bool cancelledByDriver;
        bool cancelledByPassenger;
    }

    Main public immutable mainContract;
    address public user;

    constructor(address _user,address _main) {
        user = payable(_user);
        mainContract = Main(_main);
    }

    uint256 public requiredPrice = 10;
    mapping(address => States) public userStates; // To track user state per user

    Ride[] public rides;
    Ride public curr_ride;
    address payable public curr_escrow; // to be set from Driver contract

    event RideRequested(uint256 rideId, address rider, uint256 pickupLocation, uint256 destination);
    event RideBooked(uint256 rideId, address driver, address escrowContract);

    function setRideFare(uint256 _rideId, uint256 _fare) external {
        curr_ride.fare = _fare;
        curr_ride.confirmedByDriver = true;
        curr_ride.id = _rideId;
    }

    function requestRide(uint256 _pickupLocation, uint256 _destination) public {
        curr_ride = Ride({
            id: 0, // 0 means not yet set
            passenger: user,
            driver: address(0),
            pickupLocation: _pickupLocation,
            destination: _destination,
            fare: 0, // to be set by Main.sol
            isBooked: false,
            escrowContract: payable(address(0)),
            confirmedByPassenger : false,
            confirmedByDriver: false,
            cancelledByDriver: false,
            cancelledByPassenger: false
        });

        mainContract.insertRequestedUser(user,_pickupLocation,_destination);

        emit RideRequested(curr_ride.id, msg.sender, _pickupLocation, _destination);
    }

    function getCurrRideFare() public view returns (uint rideId, uint _fare){
        require(curr_ride.confirmedByDriver == true, "Please wait a few moments while we find a driver!");
        require(curr_ride.fare != 0 , "Price not yet fixed. Please wait a few moments!");
        return (curr_ride.id,curr_ride.fare);
    }

    function bookRide(uint256 _rideId) public payable {
       // require(_rideId != rides.length + 1, "Invalid rideId or Ride does not exist!");
        require(!curr_ride.isBooked, "Ride is already booked");
        if(msg.value <= requiredPrice){
            revert notEnoughETH("Insufficient funds to book the ride",msg.value/1 ether);
        }

        (bool callSuccess, ) = curr_escrow.call{value: msg.value}("fund");
        // escrow.fund{value: msg.value}();

        if(callSuccess){
            curr_ride.escrowContract = curr_escrow;
            curr_ride.isBooked = true;
        }
        else{
            revert escrowFundingError("An error occured while funding the escrow!", callSuccess);
        }

        curr_ride.isBooked = true;
        curr_ride.confirmedByPassenger = true;
        mainContract.userBookRide(curr_ride.id);

        emit RideBooked(_rideId, msg.sender, curr_ride.escrowContract);
    }


    function getCurrentRide() public view returns (
        uint256 id,
        address passenger,
        address driver,
        uint256 pickupLocation,
        uint256 destination,
        uint256 fare,
        bool isBooked,
        address payable escrowContract,
        bool confirmedByPassenger,
        bool confirmedByDriver,
        bool cancelledByDriver,
        bool cancelledByPassenger
    ) {
        return (curr_ride.id,
        curr_ride.passenger, 
        curr_ride.driver,
         curr_ride.pickupLocation,
          curr_ride.destination, 
          curr_ride.fare,
           curr_ride.isBooked,
           curr_ride.escrowContract,
           curr_ride.confirmedByPassenger,
           curr_ride.confirmedByDriver,
           curr_ride.cancelledByDriver,
           curr_ride.cancelledByPassenger);
    }

    function getAllRides() public view returns (Ride[] memory) {
        return rides;
    }

    // Function to update user state to active
    function setUserStateActive() external {
        userStates[msg.sender] = States.active;
    }

    // Optional function to get user state
    function getUserState(address _user) public view returns (States) {
        return userStates[_user];
    }
}