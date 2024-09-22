// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/*
NOTE: 
If you want to run this code on remix, it will have to be using metamask
Also, you have to use the PoolAddressesProvider-Aave address as input to the contract
After that it will work well
I feel so good about the progress! :)
*/



//import {IFlashLoanSimpleReceiver} from "https://github.com/aave/aave-v3-core/blob/master/contracts/flashloan/interfaces/IFlashLoanSimpleReceiver.sol";

import {FlashLoanSimpleReceiverBase} from "https://github.com/aave/aave-v3-core/blob/master/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";

/*Note : In the official Aave documentation for flash loans, it is said that the contract "must conform to
the 'IFlashLoanSimpleReceiver.sol' or 'IFlashLoanReceiver.sol' interface" 

Now, it is possible to call the interface contract and then define all its variables and structures

However, our work has been made easier because there already exists another contract which is the 'base' 
contract. This contract has the necessary structure for definition of its variables and can be directly used
to implement the flash loans 

It's like having the base work done for you and you just have to build on top of it (just that here, there is now 2
levels of groundwork)
Also note that it is also possible to create your own version and play with the variables made available (and also use the functions
While also being possible to add more functions in the new contract. It is your wish.)

For this FlashLoan, we have chosen the FlashLoanSimpleReceiverBase.
*/

import {IERC20} from "https://github.com/aave/aave-v3-core/blob/master/contracts/dependencies/openzeppelin/contracts/IERC20.sol";
//Here, the IERC20 is used instead of ERC20 because we are not defining a whole new ERC20 token in this contract
//Our purpose is to simply use one of its functionalities.

contract FL is FlashLoanSimpleReceiverBase {

    address public owner;

    constructor (address _addressProvider) 
        FlashLoanSimpleReceiverBase(IPoolAddressesProvider (_addressProvider)) {
        /*
        FLSRB contract also has a constructor
        In that constructor, a variable is defined of type IPoolAddressesProvider
        Since we haven't defined that variable here, we are passing that value using encapsulation (as if typecasting it)
        and passing that to the FlashLoanSimpleReceiverBase.

        This allows us to retain the variables that will be defined in the FLSRB abstract contract as well!
        That is, variables 'POOL' that give us access to the IPool interface and all of its functions!
        (one could also retain the functions from IPoolAddressesProvider interface, more on the Explanation contract.)

        To note, that the POOL variable is to be used later.
        */

        owner = payable(msg.sender);
    }

        /*
    To note that the param 'initiator' is the same as receiver
    Although the parameters have been shifted up and down a bit, they should still be functional, we can only tell
    by working on it

    param 'asset' is the address of underlying token that will be flash borrowed
    param 'premium' is supposedly the premium fee of the flash borrowed asset
    param 'amount' is the amount of flash loan to be taken
    param 'params' these are the byte encoded params passed when initiating the flash loan, blank for us.

    returns true if executeOperation succeeds, else false
    */
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {

        uint payBack = amount + premium;
        IERC20(asset).approve(address(POOL), payBack);
        //the asset address is converted to IERC20 interface such that
        //its function 'approve' could be used upon it.
        //The approve function takes 2 parameters, an address and a value that the said address is approved to use.

        /* custom logic */ 

        return true;
    }



    function getPremium () public view returns (uint128) {
        return POOL.FLASHLOAN_PREMIUM_TOTAL();
        //In order to access the functions of an interface variable, you create a function and then call it
        //It was already discussed how we got the POOL variable so I won't be expanding on that again.

        /*
        When calling the function of an interface, first identify what its parameters and return values are
        Make them coherent with your code; and then deploy the contract to test it.
        */
    }
    
    function getPremium_Total_and_toProtocol () public view returns (uint128, uint128) {
        return (
            POOL.FLASHLOAN_PREMIUM_TOTAL(), 
            POOL.FLASHLOAN_PREMIUM_TO_PROTOCOL()
            );
        //Just playing around with the way i can return variables
        //This new way I have learnt to call functions of other interfaces is absolutely exhilarating
        //Apparently, the reason why I can do this is because there exists a contract for the Pool itself
        //that I am interacting with; and these are the values managed inside the contract.

    }