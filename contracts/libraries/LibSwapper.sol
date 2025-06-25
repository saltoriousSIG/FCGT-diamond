// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "@uniswap/swap-router-contracts/contracts/interfaces/IV3SwapRouter.sol";
import "@uniswap/swap-router-contracts/contracts/interfaces/IQuoterV2.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@solidstate/contracts/interfaces/IERC20.sol";
import "./LibTalentDiamond.sol";

library LibSwapper {
    function get_quote(
      address tokenIn, 
      address tokenOut, 
      uint24 fee, 
      uint256 amount
    ) internal returns(uint256 amount_out) {
        LibTalentDiamond.TalentBaseStorage storage tbs = LibTalentDiamond.getTalentBaseStorage();
        IQuoterV2 quoter = IQuoterV2(tbs.quoter);
        IQuoterV2.QuoteExactInputSingleParams memory params = IQuoterV2.QuoteExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            amountIn: amount,
            fee: fee,
            sqrtPriceLimitX96: 0 
        });
        (amount_out,,,) = quoter.quoteExactInputSingle(params);
    }

    function perform_swap_buy(
        address tokenOut,
        uint24 fee,
        uint256 amount,
        address sender,
        address recipient
    ) internal returns(uint256 amount_out) {
        LibTalentDiamond.TalentBaseStorage storage tbs = LibTalentDiamond.getTalentBaseStorage();
        IV3SwapRouter swapRouter = IV3SwapRouter(tbs.swaprouter);
        address WETH9 = tbs.WETH;
        if (sender != address(this)) {
            IERC20(WETH9).transferFrom(sender, recipient, amount);
        }
        uint256 quote = get_quote(WETH9, tokenOut, fee, amount);
        uint256 amountOutMinimum = quote * (10000 - tbs.max_slippage) / 10000;
        IERC20(WETH9).approve(address(swapRouter), amount);
        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter.ExactInputSingleParams({
            tokenIn: WETH9,
            tokenOut: tokenOut,
            fee: fee,
            recipient: recipient,
            amountIn: amount,
            amountOutMinimum: amountOutMinimum,
            sqrtPriceLimitX96: 0 
        });
        amount_out = swapRouter.exactInputSingle(params);
    }
    
    function perform_swap_sell(
        address tokenIn, 
        uint24 fee, 
        uint256 amount, 
        address recipient
    ) internal returns(uint256 amount_out) {
        LibTalentDiamond.TalentBaseStorage storage tbs = LibTalentDiamond.getTalentBaseStorage();
        IV3SwapRouter swapRouter = IV3SwapRouter(tbs.swaprouter);
        address WETH9 = tbs.WETH;
        uint256 quote = get_quote(tokenIn, WETH9, fee, amount);
        uint256 amountOutMinimum = quote * (10000 - tbs.max_slippage) / 10000;
        IERC20(tokenIn).approve(address(swapRouter), amount);
        IV3SwapRouter.ExactInputSingleParams memory params = IV3SwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn, 
            tokenOut: WETH9,
            fee: fee,
            recipient: recipient,
            amountIn: amount,
            amountOutMinimum: amountOutMinimum,
            sqrtPriceLimitX96: 0 
        });
        amount_out = swapRouter.exactInputSingle(params);
    }
   
}