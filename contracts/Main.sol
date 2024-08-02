// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./DriverContract.sol";
import "./User.sol";
import "./Price_fixing.sol";


error notADriver(string);
error alreadyRegistered(string);
error notAUSer(string);
// error alreadyRegistered(string);

contract Main {
    struct Pair{
        uint src;
        uint dest;
        bool exists;
    }

    struct Ride{
       uint256 rideId;
       uint256 src;
       uint256 dest; 
       uint256 fare;
       address escrow;  
       address driver;
       address passenger;
       bool confirmedByPassenger;
       bool confirmedByDriver;
       bool cancelledByDriver;
       bool cancelledByPassenger;
       bool rideCompleted;
    }

    mapping(address=>address) public driverToContracts;
    mapping(address=>address) public userToContracts;

    address[] public availableDrivers; 
    //mapping(address => bool) public availableDrivers; 

    mapping(address=>Ride) driverToOngoingRide;

    mapping(uint256=>Ride) terminatedRideHistory; // for this to work the rideId must be unique
    
    mapping(uint256 => Ride) public rides; // set from function insertRequestedUser()

    mapping(address => uint256) driverToIndex;

    Price_fixing private immutable priceFixing;

    uint256 public electedCost;

    uint256 idCounter = 1;

    modifier registeredDriversOnly(){
        if(driverToContracts[msg.sender] == address(0)){
            revert notADriver("Only registered drivers are allowed to perform this action.");
        }
        _;
    }
    modifier registeredUOnly(){
        if(userToContracts[msg.sender] == address(0)){
            revert notAUSer("Only registered users are allowed to perform this action.");
        }
        _;
    }

    event ContractDeployed(address indexed newContract);

    constructor(address _priceFixing){
       priceFixing = Price_fixing(_priceFixing);
    }

    function registerDriver() public {
        if(driverToContracts[msg.sender] != address(0)){
            revert alreadyRegistered("Driver Already registered.");
        }
        // deploy a brand new driver contract
        driverToContracts[msg.sender] = address(new DriverContract(msg.sender, address(this)));
    }
    function registerUser() public {
        if(userToContracts[msg.sender] != address(0)){
            revert alreadyRegistered("User Already registered.");
        }                  
        // deploy a brand new user contract
        userToContracts[msg.sender] = address(new User(msg.sender, address(this)));
    }

    function insertActiveDrivers(address _driver) external {
        // availableDrivers[_driver] = true;
        availableDrivers.push(_driver);
    }

    function insertRequestedUser(address _user, uint _src, uint _dest) external {

        uint256 _rideId = idCounter++;

        rides[_rideId] = Ride({
            rideId: _rideId,
            src: _src,
            dest: _dest,
            fare: 0,
            escrow: address(0),
            driver: address(0),
            passenger: _user,
            confirmedByPassenger : false,
            confirmedByDriver: false,
            cancelledByDriver: false,
            cancelledByPassenger: false,
            rideCompleted: false
        });

        selectDriverAndSendRequest(_rideId);
    }

    function selectDriverAndSendRequest(uint256 _rideId) internal {
        // Placeholder logic for selecting a driver
        //call chainlink function
        uint256 indexOfDriver = 0;
        address selectedDriver = availableDrivers[indexOfDriver]; // Replace with actual driver selection logic
        address driverContractAddress = driverToContracts[selectedDriver];

        // Assume we have a selected driver
        if (selectedDriver != address(0)) {
            DriverContract(driverContractAddress).receiveRideRequest(rides[_rideId].rideId, rides[_rideId].src, rides[_rideId].dest);
            driverToIndex[selectedDriver] = indexOfDriver;
        }
    }

    function acceptRideDriver(uint256 _rideId, address _driver, address _escrow) external {
        uint256 index = driverToIndex[_driver];

        require(availableDrivers[index] == _driver,"Driver is not available to accept this ride!");
        uint256 rideDistance = 10; // UPDATE LOGIC API call

        Ride storage ride = rides[_rideId];

        ride.driver = _driver;
        ride.escrow = _escrow;
        ride.confirmedByDriver = true;
        ride.fare = electedCost * rideDistance; // Placeholder for actual fare calculation

        //remove selected driver from available list
        availableDrivers[index] = availableDrivers[availableDrivers.length - 1];
        availableDrivers.pop();

        User(userToContracts[ride.passenger]).setRideFare(ride.rideId, ride.fare);


        //emit RideAccepted(_rideId, msg.sender);
        //emit RideFareCalculated(_rideId, ride.fare);
    }

    function userBookRide(uint256 _rideId) external {
        Ride storage ride = rides[_rideId];
        ride.confirmedByPassenger = true;
        DriverContract(driverToContracts[ride.driver]).acceptedByUser(ride.rideId);
    }
}