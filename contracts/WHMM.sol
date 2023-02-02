// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//Contract for USDC

contract WHMM is Ownable {

    address constant native = 0x332Ef44Ece256E4d99838f2AD4E63DB4754E0876; //USDC (PoS)

    uint24 feePips = 50;

    address[] wh_tokens = [
        0xF14f9596430931E177469715c591513308244e8F, //USDC.So (solana)
        0x2020b82569721DF47393505eeEDF2863D6A0504f]; //USDC.Et (ethereum)

    function native_balance() view public returns (uint256){
        return (IERC20(native).balanceOf(address(this)));
    }

    function wh_token_balance() view public returns (uint256){
        
        uint256 wh_balance = 0;

        for(uint64 wh_token_index = 0; wh_token_index < wh_tokens.length; wh_token_index++){
         wh_balance = wh_balance + IERC20(wh_tokens[wh_token_index]).balanceOf(address(this));
        }
        
        return wh_balance;
    }

    function get_fees() public view returns(uint24){
        return feePips;
    }

    function set_fees(uint24 newFees) public onlyOwner{
        feePips = newFees;
    }

    function withdraw_native_liquidity(uint256 amount) public onlyOwner returns (uint256){

        IERC20(native).transfer(msg.sender, amount);

        return amount; 
    }

    function withdraw_wh_liquidity(uint64 wh_token_index, uint256 amount) public onlyOwner returns (uint256){
        
        IERC20(wh_tokens[wh_token_index]).transfer(msg.sender, amount);

        return amount;
    }

    function swap_for_native(uint64 wh_token_index, uint256 amountIn) public returns (uint256){
        
        require(IERC20(native).balanceOf(address(this))>=amountIn);
        require(IERC20(wh_tokens[wh_token_index]).allowance(msg.sender, address(this))>=amountIn);
        require(IERC20(wh_tokens[wh_token_index]).transferFrom(msg.sender,address(this),amountIn));

        uint256 feeAmount =(amountIn * feePips) / 1e6;

        uint256 amountOut = amountIn - feeAmount;

        IERC20(native).transfer(msg.sender, amountOut);

        return amountOut;
    }

    function swap_for_wh_tokens(uint64 wh_token_index, uint256 amountIn) public returns (uint256){
        
        require(IERC20(wh_tokens[wh_token_index]).balanceOf(address(this))>=amountIn);
        require(IERC20(native).allowance(msg.sender, address(this))>=amountIn);
        require(IERC20(native).transferFrom(msg.sender,address(this),amountIn));

        uint256 feeAmount = (amountIn * feePips) / 1e6;

        uint256 amountOut = amountIn - feeAmount;

        IERC20(wh_tokens[wh_token_index]).transfer(msg.sender, amountOut);

        return amountOut;
    }
}
