// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0; 
import "../libraries/LibTalentDiamond.sol";
import "../libraries/LibSwapper.sol";
import "@solidstate/contracts/access/ownable/Ownable.sol";

contract FinalizeFacet is Ownable{ 

    event ShowFinalized (uint256 indexed show_id);

    function finalize(uint256 _show_id) public onlyOwner {
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        LibTalentDiamond.TalentBaseStorage storage tbs = LibTalentDiamond.getTalentBaseStorage();

        require(gs.shows[_show_id].state == LibTalentDiamond.ShowState.VOTING, "State must be voting");
        require(block.timestamp > gs.shows[_show_id].voting_closed_time, "Voting not closed");

        LibTalentDiamond.Show storage current_show = gs.shows[_show_id];
        IERC20 usdc_token = IERC20(tbs.USDC_TOKEN);

        // Struct to hold top three results
      
        LibTalentDiamond.Winner[3] memory winners = [LibTalentDiamond.Winner("", 0), LibTalentDiamond.Winner("", 0), LibTalentDiamond.Winner("", 0)];

        // Find top three directly
        for (uint256 i = 0; i < current_show.submissions.length; i++) {
            string memory entry_id = current_show.submissions[i];
            uint256 count = current_show.num_votes_by_id[entry_id];
            if (count > winners[0].count) {
                winners[2] = winners[1];
                winners[1] = winners[0];
                winners[0] = LibTalentDiamond.Winner(entry_id, count);
            } else if (count > winners[1].count) {
                winners[2] = winners[1];
                winners[1] = LibTalentDiamond.Winner(entry_id, count);
            } else if (count > winners[2].count) {
                winners[2] = LibTalentDiamond.Winner(entry_id, count);
            }
        }


        uint256 total_usdc = current_show.prize_pool_usdc;
        uint256 platform_fee = (total_usdc * tbs.show_percentage) / 10000;
        uint256 balance = total_usdc - platform_fee;
        uint256 prize_pool = (balance * 7000) / 10000;
        uint256 buyback_amount = balance - prize_pool;


        require(usdc_token.transfer(msg.sender, platform_fee), "Platform fee transfer failed");
        // Distribute prizes

        if (current_show.submissions.length == 1) { 
            require(usdc_token.transfer(current_show.submissions_by_id[winners[0].id].user_address, prize_pool), "First prize transfer failed");
        } else if (current_show.submissions.length == 2) { 
            uint256 first_prize = (prize_pool * 7000) / 10000;
            uint256 second_prize = (prize_pool * 3000) / 10000;
            require(usdc_token.transfer(current_show.submissions_by_id[winners[0].id].user_address, first_prize), "First prize transfer failed");
            require(usdc_token.transfer(current_show.submissions_by_id[winners[1].id].user_address, second_prize), "Second prize transfer failed");
        } else { 
            uint256 first_prize = (prize_pool * tbs.winner_percentage) / 10000;
            uint256 second_prize = (prize_pool * tbs.second_percentage) / 10000;
            uint256 third_prize = prize_pool - first_prize - second_prize;
            require(usdc_token.transfer(current_show.submissions_by_id[winners[0].id].user_address, first_prize), "First prize transfer failed");
            require(usdc_token.transfer(current_show.submissions_by_id[winners[1].id].user_address, second_prize), "Second prize transfer failed");
            require(usdc_token.transfer(current_show.submissions_by_id[winners[2].id].user_address, third_prize), "Third prize transfer failed");
        }

        uint256 weth_out = LibSwapper.perform_swap_sell(tbs.USDC_TOKEN, tbs.usdc_pool_fee, buyback_amount, address(this));
        LibSwapper.perform_swap_buy(tbs.TALENT_TOKEN, tbs.talent_pool_fee, weth_out, address(this), address(this));
        current_show.state = LibTalentDiamond.ShowState.CLOSED;
        emit ShowFinalized(_show_id);
    }
}