// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
import "@solidstate/contracts/access/ownable/Ownable.sol";
import "../libraries/LibTalentDiamond.sol";

contract StartShowFacet is Ownable {
    event ShowStarted (uint256 indexed show_id, uint256 start_time, uint256 entry_closed_time, uint256 voting_closed_time);
    function startShow(uint256 _start_time, uint256 _entry_closed_time, uint256 _voting_closed_time, string calldata name, string calldata descripiton, string calldata tags) public onlyOwner { 
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        uint256 current_show_id = gs.current_show_id;
        gs.shows[current_show_id].state = LibTalentDiamond.ShowState.STARTED;
        gs.shows[current_show_id].start_time = _start_time;
        gs.shows[current_show_id].entry_closed_time = _entry_closed_time;
        gs.shows[current_show_id].voting_closed_time = _voting_closed_time;
        gs.shows[current_show_id].name = name;
        gs.shows[current_show_id].description = descripiton;
        gs.shows[current_show_id].tags = tags;
        gs.current_show_id++;
        emit ShowStarted(current_show_id, _start_time, _entry_closed_time, _voting_closed_time);
    }
}
