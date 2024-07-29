// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Escrow {
    enum States {
        initialized,
        ongoing,
        terminated
    }

    address public driver; //default visibility is internal
    address public passenger;
    uint public balance;
    uint8 public driverShare; //in range of 0 to 1
    uint8 public passengerShare; //in range of 0 to 1
    States public state;
    bool public pendingPayment;

    constructor(address _driver, address _pass) payable {
        driver = _driver;
        passenger = _pass;
        balance = msg.value;
        driverShare = 1;
        passengerShare = 0;
    }

    function getDriverShare() public view returns (uint8) {
        return driverShare;
    }

    function getEscrowBalance() public view returns (uint) {
        return address(this).balance;
    }

    function disperse() public {
        (bool sent, ) = driver.call{value: address(this).balance}("");
        if (!sent) {
            pendingPayment = true;
        }
    }
}
