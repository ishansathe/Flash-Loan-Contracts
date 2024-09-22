// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import {IFlashLoanSimpleReceiver} from '../interfaces/IFlashLoanSimpleReceiver.sol';
import {IPoolAddressesProvider} from '../../interfaces/IPoolAddressesProvider.sol';
import {IPool} from '../../interfaces/IPool.sol';

/**
 * @title FlashLoanSimpleReceiverBase
 * @author Aave
 * @notice Base contract to develop a flashloan-receiver contract.
 */
abstract contract FlashLoanSimpleReceiverBase is IFlashLoanSimpleReceiver {
  IPoolAddressesProvider public immutable override ADDRESSES_PROVIDER;

  //Note: ALLCAPS is just a naming convention in solidity to represent immutable variables
  //You can also see this trend in C/C++ programming

  /*
    Here, a variable is declared to be of type IPoolAddressesProvider.
    This type is actually an interface that has been inherited into this smart contract
    This allows us to call various functions of the interface at will using the variable itself.

    But here, in the constructor, only one of the functions is used. Which is also fine, we can override it later.
  */

  IPool public immutable override POOL;
  /*
    Again, a variable has been declared over here to be of type IPool
    Like the IPoolAddressesProvider, this interface also has a vast set of functions that we don't actually understand
    To be noted that the functions in the 2 libraries are quite different.
  */

  constructor(IPoolAddressesProvider provider) {
    ADDRESSES_PROVIDER = provider;
    POOL = IPool(provider.getPool());
    /*
      Here, the getPool function from the IPoolAddressesProvider interface is used in correspondence to the provider address
      Value of that is typecasted into the IPool interface and then stored inside variable POOL.
    */
  }
}