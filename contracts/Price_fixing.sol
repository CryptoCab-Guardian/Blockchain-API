// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

error notADriver(string);
error negativePrice(string);
error alreadyCastedPrice(string);
error intermittentContractState(string);
error ongoingContractState(string);
error didNotCastBefore(string);
error noFeedsCastedYet(string description);
error alreadyRegistered(string);

contract Price_fixing{
    enum State{
        Ongoing,
        Intermittent
    }
    State public contractState;
    mapping(address => bool) internal drivers;
    mapping(address => uint) public pricesCasted;
    uint public currentPriceFixed;

    address[] public addressesOfDrivers_Casted; // required only for calculating the meedian (getting number of drivers who casted their feeds)

    modifier registeredDriversOnly(){
        if(drivers[msg.sender] != true){
            revert notADriver("Only registered drivers are allowed to cast a price view.");
        }
        _;
    }

    modifier ongoingContractStateOnly(){
         if(contractState != State.Ongoing){
            revert intermittentContractState("Currently the contract is not accepting any feeds!");
        }
        _;
    }

    //For testing purposes only
    function registerDriver() public {
        if(drivers[msg.sender] == true){
            revert alreadyRegistered("Driver Already registered.");
        }
        drivers[msg.sender] = true;
    }

    function startConsensusBasedPriceFixingSession() public {
        if(contractState == State.Ongoing){
            revert ongoingContractState("Contract already in 'Ongoing' state");
        }
        contractState = State.Ongoing;
    }

    function terminateConsensusBasedPriceFixingSession() public ongoingContractStateOnly{
        contractState = State.Intermittent ;
    }
    
    function castPriceView(uint _price) public registeredDriversOnly ongoingContractStateOnly{       
        if(_price < 0){
            revert negativePrice("Please enter a positive price value!");
        }
        if(pricesCasted[msg.sender] > 0){
            revert alreadyCastedPrice("Please refer to the updateCast() function to update your feed.");
        }
        pricesCasted[msg.sender] = _price;
        addressesOfDrivers_Casted.push(msg.sender);
    }

    function updateCast(uint _updatedPrice) public registeredDriversOnly ongoingContractStateOnly{
        if(pricesCasted[msg.sender] == 0){
            revert didNotCastBefore("Please refer to the castPriceView() function to first cast a price view before manipulating it.");
        }
        pricesCasted[msg.sender] = _updatedPrice ;
    }

    function removeCast() public  registeredDriversOnly ongoingContractStateOnly{
        if(pricesCasted[msg.sender] == 0){
            revert didNotCastBefore("Please refer to the castPriceView() function to first cast a price view before manipulating it.");
        }
        pricesCasted[msg.sender] = 0;
    }

    

    function calculateMedian() public {
        uint count = addressesOfDrivers_Casted.length;

        if(count == 0){
            revert noFeedsCastedYet("No feeds casted yet! Cannot calculate median!");
        }

        // Create an array to store the prices
        uint[] memory prices = new uint[](count);
        uint index = 0;
        for (uint i = 0; i < count; i++) {
            address addr = addressesOfDrivers_Casted[i];      
            if (pricesCasted[addr] > 0) {    // check required since a driver might delete his account after casting his feed and that operation would be reflected in the mapping
                prices[index] = pricesCasted[addr];
                index++;
            }
        }

        // Resize the nonZeroPrices array to remove any empty elements
        assembly {
            mstore(prices, index)
        }

        // Sort the array
        sort(prices);

        // Calculate median
        if (index % 2 == 0) {
            // If count is even, return the average of the two middle values
            currentPriceFixed = (prices[index / 2 - 1] + prices[index / 2]) / 2;
        } else {
            // If count is odd, return the middle value
            currentPriceFixed = prices[index / 2];
        }
    }

    function sort(uint[] memory arr) internal pure {
        for (uint i = 0; i < arr.length; i++) {
            for (uint j = i + 1; j < arr.length; j++) {
                if (arr[i] > arr[j]) {
                    uint temp = arr[i];
                    arr[i] = arr[j];
                    arr[j] = temp;
                }
            }
        }
    }

    /*xxxxxxxxxxxxxxxxxxxxxxxxx GETTERS xxxxxxxxxxxxxxxxxxxxxxxxx*/

    function getDrivers_casted() public view returns (address[] memory){
        return addressesOfDrivers_Casted ;
    }

    function getCastedPrice(address _driver) public view returns (uint) {
        return pricesCasted[_driver];
    }
}