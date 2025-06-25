// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0; 
import "../libraries/LibTalentDiamond.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SubmitEntryFacet { 
    event EntrySubmitted (uint256 indexed show_id, string entry_id, address user_address);
    function submit_entry(uint256 _show_id, LibTalentDiamond.Entry calldata entry) public { 
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        LibTalentDiamond.TalentBaseStorage storage tbs = LibTalentDiamond.getTalentBaseStorage();

        require(gs.shows[_show_id].state == LibTalentDiamond.ShowState.STARTED, "Show not elligible for submissions");
        require(block.timestamp >= gs.shows[_show_id].start_time && block.timestamp < gs.shows[_show_id].entry_closed_time, "submitting period closed");
        require(gs.shows[_show_id].submissions_by_id[entry.entry_id].user_address == address(0), "Entry ID already exists");
        require(gs.user_entry[_show_id][msg.sender].user_address == address(0), "Already submitted for this show");

        IERC20 token = IERC20(tbs.USDC_TOKEN);
        token.transferFrom(msg.sender, address(this), tbs.token_entry_price);
        gs.shows[_show_id].submissions_by_id[entry.entry_id] = entry;
        gs.shows[_show_id].submissions.push(entry.entry_id);
        gs.shows[_show_id].participants.push(msg.sender);
        gs.shows[_show_id].prize_pool_usdc += tbs.token_entry_price;
        gs.user_entry[_show_id][msg.sender] = entry;

        emit EntrySubmitted(_show_id, entry.entry_id, msg.sender);
    } 
}