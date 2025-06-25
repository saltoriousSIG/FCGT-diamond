// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0; 
import "../libraries/LibTalentDiamond.sol";
import "@solidstate/contracts/security/reentrancy_guard/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CastVoteFacet is ReentrancyGuard { 
    event VoteCast (uint256 indexed show_id, string indexed entry_id, address indexed user_address);

    modifier maxThreeVotesPerShow(uint256 _show_id) { 
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        LibTalentDiamond.Show storage current_show = gs.shows[_show_id];
        uint256 num_total_votes = current_show.votes_cast[msg.sender];
        require(num_total_votes < 3, "You used all your votes");
        _;
    }

    modifier onlyOneTlntVote(uint256 _show_id, LibTalentDiamond.VoteCurrency _vote_currency) { 
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        LibTalentDiamond.Show storage current_show = gs.shows[_show_id];
        if (current_show.used_tlnt_vote[msg.sender]) { 
            require(_vote_currency == LibTalentDiamond.VoteCurrency.USDC, "You already voted with TLNT");
        } 
        _;
    }

   function vote(uint256 _show_id, LibTalentDiamond.Vote calldata _vote) public nonReentrant maxThreeVotesPerShow(_show_id) onlyOneTlntVote(_show_id, _vote.vote_currency) { 
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        LibTalentDiamond.TalentBaseStorage storage tbs = LibTalentDiamond.getTalentBaseStorage();


        require(gs.shows[_show_id].state == LibTalentDiamond.ShowState.VOTING, "Voting not open");
        require(block.timestamp > gs.shows[_show_id].entry_closed_time && block.timestamp < gs.shows[_show_id].voting_closed_time, "submitting period closed");
        require(gs.shows[_show_id].submissions_by_id[_vote.selected_entry_id].user_address != address(0), "Invalid entry ID");

        if (!gs.shows[_show_id].has_voted[msg.sender]) { 
            gs.shows[_show_id].voters.push(msg.sender);
            gs.shows[_show_id].has_voted[msg.sender] = true;
        }

        if (_vote.vote_currency == LibTalentDiamond.VoteCurrency.TLNT) { 
            gs.shows[_show_id].used_tlnt_vote[msg.sender] = true;
            IERC20 tlnt_token = IERC20(tbs.TALENT_TOKEN);
            tlnt_token.transferFrom(msg.sender, address(this), tbs.vote_price);
        } else { 
            IERC20 usdc_token = IERC20(tbs.USDC_TOKEN);
            usdc_token.transferFrom(msg.sender, address(this), tbs.vote_price);
            gs.shows[_show_id].prize_pool_usdc += tbs.vote_price;
        }

        gs.shows[_show_id].votes.push(_vote);
        gs.shows[_show_id].votes_cast[msg.sender]++;
        gs.shows[_show_id].num_votes_by_id[_vote.selected_entry_id]++;
        emit VoteCast(_show_id, _vote.selected_entry_id, msg.sender);
    } 
}