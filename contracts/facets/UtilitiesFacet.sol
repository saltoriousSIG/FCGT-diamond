// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0; 
import "../libraries/LibTalentDiamond.sol";
import "@solidstate/contracts/access/ownable/Ownable.sol";

contract UtilitiesFacet is Ownable { 
    event ShowStateUpdated (uint256 indexed show_id, LibTalentDiamond.ShowState state);

    function updateTalentToken(address _new_talent_token) public onlyOwner {
        LibTalentDiamond.TalentBaseStorage storage tbs = LibTalentDiamond.getTalentBaseStorage();
        tbs.TALENT_TOKEN = _new_talent_token;
    }

    function updateUSDCToken(address _new_usdc_token) public onlyOwner {
        LibTalentDiamond.TalentBaseStorage storage tbs = LibTalentDiamond.getTalentBaseStorage();
        tbs.USDC_TOKEN = _new_usdc_token;
    }

    function updateTokenEntryPrice(uint256 _new_price) public onlyOwner {
        LibTalentDiamond.TalentBaseStorage storage tbs = LibTalentDiamond.getTalentBaseStorage();
        tbs.token_entry_price = _new_price;
    }

    function updateVoteReward(uint256 _new_reward) public onlyOwner { 
        LibTalentDiamond.TalentBaseStorage storage tbs = LibTalentDiamond.getTalentBaseStorage();
        tbs.vote_reward = _new_reward;
    }

    function updateVotePrice(uint256 _new_vote_price) public onlyOwner {
        LibTalentDiamond.TalentBaseStorage storage tbs = LibTalentDiamond.getTalentBaseStorage();
        tbs.vote_price = _new_vote_price;
    }

    function updateShowPercentage(uint256 _show_percentage) public onlyOwner { 
        LibTalentDiamond.TalentBaseStorage storage tbs = LibTalentDiamond.getTalentBaseStorage();
        tbs.show_percentage = _show_percentage;
    }

    function updateShowData(
        uint256 _show_id, 
        string calldata name, 
        string calldata description, 
        string calldata tags
    ) public onlyOwner { 
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        require(_show_id > 0 && _show_id <= gs.current_show_id, "Invalid show ID");
        LibTalentDiamond.Show storage current_show = gs.shows[_show_id];
        current_show.name = name;
        current_show.description = description;
        current_show.tags = tags;
    }

    function updateWinningPercentages(uint256 _winner_percentage, uint256 _second_percentage, uint256 _third_percentage ) public onlyOwner { 
        LibTalentDiamond.TalentBaseStorage storage tbs = LibTalentDiamond.getTalentBaseStorage();
        require(_winner_percentage + _second_percentage + _third_percentage == 10000, "WE10k");
        tbs.winner_percentage = _winner_percentage;
        tbs.second_percentage = _second_percentage;
        tbs.third_percentage = _third_percentage;
    }

    function updateShowState(uint256 _show_id, LibTalentDiamond.ShowState _show_state) public onlyOwner { 
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        gs.shows[_show_id].state = _show_state;
        emit ShowStateUpdated(_show_id, _show_state);
    }
}