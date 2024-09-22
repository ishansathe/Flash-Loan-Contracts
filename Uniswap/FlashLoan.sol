
/*
Understand that in this code, as we run it on Remix, as per the tutorial, we send 1 USDC to this contract.
However, that is not necessary. 
It is sort of an overkill, what is required that the contract have some base fees that it would have to pay for the flash loan!
when we request a flash loan of 1 USDC, the contract needs to pay have 0.05% of that loaned amount as fee to Aave.
So, what we actually pay is :-
        1 USDC has 6 zeroes for the decimal place
        so 1000000
        and, when we take a flash loan of 1 USDC,
        the fee/premium paid to Aave, will be:
        500
        Remaining tokens inside the contract, after having successfully executed the contract will be:
        999500
*/

/*
Note:
    This contract has a withdraw function
    The reason is that if not, the funds would be bricked
    Note that any profits from the Flash Loan would be returned to the contract and act as funds/balance of the contract.
    Hence, the withdraw function allows us to withdraw any specific tokens (as per the token contract address) from the contract. 
    
Also Note:
    This contract is a simple one and only executes a flash loan
    We have not included any logic in here. (Which is to be included under the 'executeOperation' function)
    Hence, the results after getting the flash loan executed, will be just the original amount minus the deducted fee.
*/

//SPDX-License-Identifier:MIT

pragma solidity ^0.8.10;

//Accprding to Aave documentation:
import {FlashLoanSimpleReceiverBase} from "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
//Need to implement this interface in order to be the receiver of loan.
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
//IPoolAddressesProvider is like a layer of asbtraction away from pool address. 
import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";
//We get the approve function from here

contract FlashLoan is FlashLoanSimpleReceiverBase {
    address payable owner;
    //We withdraw from the function and give access to the owner


    //Here, 2 constructors are called, first of this one, and then of the contract that we are calling
    constructor (address _addressProvider)  
        FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider))
    {
        owner = payable(msg.sender);
    }
    
    function executeOperation(
        address asset,
        //token
        uint256 amount,
        //amount being borrowed
        uint256 premium,
        //Loan fee
        address initiator,
        //Entity that triggered the borrowing (irrelevant in our case)
        bytes calldata params
        //byte encoded params passed when initiating the flash loan
        //last 2 are not going to be used.
    ) external override returns (bool) {
        //Since we have copied a function from a contract we are inheriting, we have to override this function
        
        //We have funds in hand
        
        uint256 amountOwed = amount + premium;
        //This is the amount we need to approve in the pool contract

        IERC20(asset).approve(address(POOL), amountOwed);
        //The POOL variable is initiated in the FlashLoan receciver contract by its constructor, and hence we can use it.
        
        return true;
    }

    function requestFlashLoan(address _token, uint _amount) public {

        address receiverAddress = address(this);
        //address(this) means address of this contract.
        address asset = _token;
        uint amount = _amount;

        //For params and referral code, we pass the default values
        //If you forget the datatype, you can go back into interface and check it out.
        bytes memory params = '';
        uint16 referralCode = 0;


        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );

    }

    function getBalance(address _tokenAddress) external view returns (uint) 
    {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
        //All the holdings of this contract for this particular token
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
        //placeholder for rest of code.
    }

    receive() external payable {}
    
}