//SPDX-License-Identifier:MIT

pragma solidity 0.8.10;

import {FlashLoanSimpleReceiverBase} from "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

interface IDex {
    function depositUSDC(uint256 _amount) external;

    function depositDAI(uint256 _amount) external;

    function buyDAI() external;

    function sellDAI() external;
}
//In order to use the Dex.sol contract, we need to create an interface of it
//So, we have done so.

contract FlashLoanArbitrage is FlashLoanSimpleReceiverBase {
    address payable owner;

    // Aave ERC20 Token addresses on Goerli network
    address private immutable daiAddress =
        0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357;
    address private immutable usdcAddress =
        0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8;
    address private dexContractAddress =
        0x410f010B18Db38E5aFAfB85B47934F0dFa005a49;

    IERC20 private dai;
    IERC20 private usdc;
    IDex private dexContract;
/*
    Here, we are instantiating the tokens newly.
    As you can see, we are making use of the Interfaces in order to invoke the original smart contract
    IERC20 interface calls the ERC20 contract and instantiates the dai and usdc tokens
    And
    IDex interface calls the Dex.sol contract and instantiates dexContract (an object for this contract)
*/


    constructor(address _addressProvider)
        FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider))
    {
        owner = payable(msg.sender);

        dai = IERC20(daiAddress);
        usdc = IERC20(usdcAddress);
        dexContract = IDex(dexContractAddress);

        /*
            Here, we see that all the previously instantiated tokens and the object, are now being given values
            The interface is being called upon those addresses
            dai and usdc addresses contain the token contract addresses and hence will be coinciding with those specific tokens

            (So, an intuition is that if we want to go towards the real DAI and USDC, we will have to find out the 
            real token contract address and change it here.)

            The DEX contract address is as when we had deployed it.
            In the testing environment, we have it as is

            Intuition is that, in real time arbitrage, we would want to find out the address of the real DEXs and 
            also understand it's functions. We want it to have both borrow and deposit functions.
            We also know that we would need 2 DEXs
            Our Dex.sol is merely a simulation of 2 DEXs making our work easy.
        */
    }

    /**
        This function is called after your contract has received the flash loaned amount
     */
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        //
        // This contract now has the funds requested.
        // Your logic goes here.
        //

        // Arbirtage operation
        dexContract.depositUSDC(1000000000); // 1000 USDC
        dexContract.buyDAI();
        dexContract.depositDAI(dai.balanceOf(address(this)));
        dexContract.sellDAI();

        // At the end of your logic above, this contract owes
        // the flashloaned amount + premiums.
        // Therefore ensure your contract has enough to repay
        // these amounts.

        // Approve the Pool contract allowance to *pull* the owed amount
        uint256 amountOwed = amount + premium;
        IERC20(asset).approve(address(POOL), amountOwed);

        return true;
    }

    function requestFlashLoan(address _token, uint256 _amount) public {
        address receiverAddress = address(this);
        address asset = _token;
        uint256 amount = _amount;
        bytes memory params = "";
        uint16 referralCode = 0;

        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );
    }

    function approveUSDC(uint256 _amount) external returns (bool) {
        return usdc.approve(dexContractAddress, _amount);
    }

    function allowanceUSDC() external view returns (uint256) {
        return usdc.allowance(address(this), dexContractAddress);
    }

    function approveDAI(uint256 _amount) external returns (bool) {
        return dai.approve(dexContractAddress, _amount);
    }

    function allowanceDAI() external view returns (uint256) {
        return dai.allowance(address(this), dexContractAddress);
    }

    function getBalance(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }

    receive() external payable {}
}