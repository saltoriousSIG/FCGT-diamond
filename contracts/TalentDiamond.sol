// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "@solidstate/contracts/proxy/diamond/SolidStateDiamond.sol";
import "./libraries/LibTalentDiamond.sol";
import "@solidstate/contracts/interfaces/IERC2535DiamondCutInternal.sol";

contract TalentDiamond is SolidStateDiamond {
    struct ConstructorParams { 
        address talent_token; 
        address usdc_token; 
        address weth;
        address swaprouter;
        address quoter;
        uint24 usdc_pool_fee;
        uint24 talent_pool_fee;  
        uint256 max_slippage;
        uint256 token_entry_price; 
        uint256 vote_reward; 
        uint256 vote_price;
        uint256 winner_percentage;
        uint256 second_percentage;
        uint256 third_percentage;
        uint256 show_percentage;
    }
    

    constructor(ConstructorParams memory params) {
        LibTalentDiamond.TalentBaseStorage storage s = LibTalentDiamond.getTalentBaseStorage();
        s.TALENT_TOKEN = params.talent_token;
        s.USDC_TOKEN = params.usdc_token;
        s.WETH = params.weth;
        s.swaprouter = params.swaprouter;  
        s.quoter = params.quoter;
        s.usdc_pool_fee = params.usdc_pool_fee;
        s.talent_pool_fee = params.talent_pool_fee;
        s.max_slippage = params.max_slippage;
        s.token_entry_price = params.token_entry_price;
        s.vote_reward = params.vote_reward;
        s.vote_price = params.vote_price;
        s.winner_percentage = params.winner_percentage;
        s.second_percentage = params.second_percentage;
        s.third_percentage = params.third_percentage;
        s.show_percentage = params.show_percentage;
    }
   
}