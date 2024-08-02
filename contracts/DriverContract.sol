// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./Escrow.sol";
import "./Main.sol";

error notReceivingRides(string);
error pendingRequest(string);
error noPendingRides(string);
error driverOnly(string);
error userNotRequested(string, address passenger);

contract DriverContract {
    enum States {
        inactive,
        ongoing,
        accepting
    }

    struct Ride {
        uint256 rideId;
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

    address payable public driver;
    States public state;
    Ride public curr_ride;
    Ride[] public rides;
    Escrow public curr_escrow;
    address public pendingPaymentEscrowAddress;

    modifier accepting() {
        if (state != States.accepting) {
            revert notReceivingRides("currently driver is not receiving any rides.");
        }
        _;
    }

    constructor(address _driver, address _main) {
        driver = payable(_driver);
        mainContract = Main(_main);
    }

    function setStateAccepting() public {
        state = States.accepting;
        mainContract.insertActiveDrivers(driver);
    }

    function setStateInactive() external {
        state = States.inactive;
    }

    function receiveRideRequest(uint _rideId, uint _src, uint _dest) external  accepting {
        curr_ride = Ride({
            rideId:_rideId,
            passenger: address(0),
            driver: driver,
            pickupLocation: _src,
            destination: _dest,
            fare: 0, // to be set by Main.sol
            isBooked: false,
            escrowContract: payable(address(0)),
            confirmedByPassenger : false,
            confirmedByDriver: false,
            cancelledByDriver: false,
            cancelledByPassenger: false
        });
    }

    function acceptRideRequest() public payable accepting {
        if (msg.sender != driver) {
            revert driverOnly("Only the owner driver can accept his ride.");
        }
        require(msg.value >= 1000000000000000000, "Provide enough ETH!!");


        // Deploy funded Escrow contract
        curr_escrow = new Escrow{value: msg.value}(driver, curr_ride.passenger);

        curr_ride.confirmedByDriver= true;
        curr_ride.escrowContract= payable(address(curr_escrow));

        mainContract.acceptRideDriver(curr_ride.rideId, driver, address(curr_escrow));

        emit RideAcceptedByDriver(curr_ride.pickupLocation, address(curr_escrow));
    }

    function acceptedByUser(uint256 rideId) external {
        require(rideId == curr_ride.rideId, "wrong ride");
        curr_ride.confirmedByPassenger = true;
    }

    

    // function terminateOngoingRide() public {
    //     setStateAccepting();
    //     curr_ride.completed = true;
    //     curr_escrow.disperse();
    //     rides.push(curr_ride);
    //     resetCurrentRide();
    // }

    function fetchCurrentRideDetails(
        
    ) public view returns (Ride memory) {
        return (curr_ride);
    }

    // function resetCurrentRide() public {
    //     curr_ride.pending = false;
    //     curr_ride.completed = false;
    //     curr_ride.source = 0;
    //     curr_ride.destination = 0;
    //     curr_ride.passenger = address(0);
    // }

    function getDriverBalance() public view returns (uint) {
        return address(driver).balance;
    }

    function getEscrowBalance() public view returns (uint) {
        return address(curr_escrow).balance;
    }

    event RideAcceptedByDriver(uint indexed source, address indexed escrowContract);
}