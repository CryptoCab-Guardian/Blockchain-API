// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Escrow {
    enum States {
        initialized,
        ongoing,
        terminated
    }

    address public driver;
    address public passenger;
    uint public balance;
    uint8 public driverShare;
    uint8 public passengerShare;
    States public state;
    bool public pendingPayment;

    constructor(address _driver, address _pass) payable {
        driver = _driver;
        passenger = _pass;
        balance = msg.value;
        driverShare = 1;
        passengerShare = 0;
        state = States.initialized;
    }

    function fund() public payable {
        require(state == States.initialized || state == States.ongoing, "Cannot fund in current state");
        balance += msg.value;
        state = States.ongoing;
    }

    function disperse() public {
        require(state == States.ongoing, "Escrow must be in ongoing state to disperse funds");
        (bool sent, ) = driver.call{value: address(this).balance}("");
        if (!sent) {
            pendingPayment = true;
        }
        state = States.terminated;
    }

    function getDriverShare() public view returns (uint8) {
        return driverShare;
    }

    function getEscrowBalance() public view returns (uint) {
        return address(this).balance;
    }
}