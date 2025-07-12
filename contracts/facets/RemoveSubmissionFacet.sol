// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0; 
import "../libraries/LibTalentDiamond.sol";
import "@solidstate/contracts/access/ownable/Ownable.sol";
import "@solidstate/contracts/security/reentrancy_guard/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract RemoveSubmissionFacet is Ownable, ReentrancyGuard {
    event EntryRemoved (uint256 show_id, string entry_id, address user_address);
    function remove_submission(uint256 _show_id, string calldata _entry_id) public onlyOwner nonReentrant {
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        LibTalentDiamond.TalentBaseStorage storage tbs = LibTalentDiamond.getTalentBaseStorage();

        IERC20 token = IERC20(tbs.USDC_TOKEN);

        require(gs.shows[_show_id].state == LibTalentDiamond.ShowState.VOTING, "Incorrect State"); 
        require(token.balanceOf(address(this)) >= tbs.token_entry_price, "not enough tokens");

        LibTalentDiamond.Entry memory submission = gs.shows[_show_id].submissions_by_id[_entry_id];

        for (uint256 i = 0; i < gs.shows[_show_id].participants.length; i++) {
            if (gs.shows[_show_id].participants[i] == submission.user_address) {
                gs.shows[_show_id].participants[i] = gs.shows[_show_id].participants[gs.shows[_show_id].participants.length - 1];
                gs.shows[_show_id].participants.pop();
                break;
            }
        }

        //remove submission from submission array
        for (uint256 i = 0; i < gs.shows[_show_id].submissions.length; i++) {
            if (keccak256(abi.encodePacked(gs.shows[_show_id].submissions[i])) == keccak256(abi.encodePacked(_entry_id))) {
                gs.shows[_show_id].submissions[i] = gs.shows[_show_id].submissions[gs.shows[_show_id].submissions.length - 1];
                gs.shows[_show_id].submissions.pop();
                break;
            }
        }

        //refund anyone who voted for this submission
        for (uint256 i = 0; i < gs.shows[_show_id].votes.length; i++) {
            if (keccak256(abi.encodePacked(gs.shows[_show_id].votes[i].selected_entry_id)) == keccak256(abi.encodePacked(_entry_id))) {
                address voter_address = gs.shows[_show_id].votes[i].voter_address;
                gs.shows[_show_id].num_votes_by_id[_entry_id]--;
                gs.shows[_show_id].votes_cast[voter_address]--;
                if (gs.shows[_show_id].votes_cast[voter_address] == 0) { 
                    gs.shows[_show_id].has_voted[voter_address] = false;
                }
                gs.shows[_show_id].prize_pool_usdc -= tbs.vote_price;
                gs.shows[_show_id].votes[i] = gs.shows[_show_id].votes[gs.shows[_show_id].votes.length - 1];
                gs.shows[_show_id].votes.pop();
                token.transfer(voter_address, tbs.vote_price);
            }
        }

        gs.shows[_show_id].prize_pool_usdc -= tbs.token_entry_price;

        delete gs.shows[_show_id].submissions_by_id[_entry_id];
        delete gs.shows[_show_id].submissions_by_address[submission.user_address];
        delete gs.user_entry[_show_id][submission.user_address];

        token.transfer(submission.user_address, tbs.token_entry_price);
        emit EntryRemoved(_show_id, submission.entry_id, submission.user_address); 
    }
}