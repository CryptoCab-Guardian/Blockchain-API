// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./DriverContract.sol";

error notADriver(string);
error alreadyRegistered(string);

contract Main {
    mapping(address=>address) public driverToContracts;

    modifier registeredDriversOnly(){
        if(driverToContracts[msg.sender] == address(0)){
            revert notADriver("Only registered drivers are allowed to perform this action.");
        }
        _;
    }

    event ContractDeployed(address indexed newContract);

    function registerDriver() public {
        if(driverToContracts[msg.sender] != address(0)){
            revert alreadyRegistered("Driver Already registered.");
        }
        // deploy a brand new driver contract
        driverToContracts[msg.sender] = address(new DriverContract(msg.sender));
    }
}