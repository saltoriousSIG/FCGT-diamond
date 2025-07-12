// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0; 
import "../libraries/LibTalentDiamond.sol";

contract DataFacet { 
    struct ShowDataResponse { 
        address[] participants;
        string[] submissions;
        LibTalentDiamond.Vote[]  votes;
        LibTalentDiamond.ShowState state;
        uint256 prize_pool_usdc;
        uint256 start_time;
        uint256 entry_closed_time;
        uint256 voting_closed_time;
        string  name;
        string  description;
        string tags;
        address[] voters;
    }

    function fetch_show_data(uint256 _show_id) public view returns(ShowDataResponse memory show_data) {
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();  
        LibTalentDiamond.Show storage current_show = gs.shows[_show_id];
        show_data.participants = current_show.participants;
        show_data.submissions = current_show.submissions;
        show_data.votes = current_show.votes;
        show_data.state = current_show.state;
        show_data.prize_pool_usdc = current_show.prize_pool_usdc;
        show_data.start_time = current_show.start_time;
        show_data.entry_closed_time = current_show.entry_closed_time;
        show_data.voting_closed_time = current_show.voting_closed_time;
        show_data.name = current_show.name;
        show_data.description = current_show.description;
        show_data.tags = current_show.tags;
        show_data.voters = current_show.voters;
    }

    function fetch_base_data() public pure returns(LibTalentDiamond.TalentBaseStorage memory base_data) { 
        LibTalentDiamond.TalentBaseStorage storage bs = LibTalentDiamond.getTalentBaseStorage();
        base_data = bs;
    }

    function fetch_submissions(uint256 _show_id) public view returns(LibTalentDiamond.Entry[] memory submissions) { 
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        LibTalentDiamond.Show storage current_show = gs.shows[_show_id];
        submissions = new LibTalentDiamond.Entry[](current_show.submissions.length);
        for (uint256 i = 0; i < current_show.submissions.length ; i++) { 
            submissions[i] = current_show.submissions_by_id[current_show.submissions[i]];
        }
    } 

    function fetch_submission_by_id(uint256 _show_id, string calldata _entry_id)  public view returns (LibTalentDiamond.Entry memory entry) { 
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        entry = gs.shows[_show_id].submissions_by_id[_entry_id];
    }

    function fetch_entry_by_address(uint256 _show_id, address _user) public view returns(LibTalentDiamond.Entry memory submission) { 
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        submission = gs.user_entry[_show_id][_user];
    }

    function fetch_num_votes_cast_by_address(uint256 _show_id, address _user) public view returns(uint256 num_votes_cast) { 
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        num_votes_cast = gs.shows[_show_id].votes_cast[_user];
    }

    function fetch_current_show_id() public view returns(uint256 id) { 
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        id = gs.current_show_id;
    }

    function fetch_votes_by_entry_id(uint256 _show_id, string calldata _entry_id) public view returns(LibTalentDiamond.Vote[] memory vote) { 
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        vote = gs.shows[_show_id].votes_by_id[_entry_id];
    }

    function fetch_num_votes_by__entry_id(uint256 _show_id, string calldata _entry_id) public view returns(uint256 num_votes) { 
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        num_votes = gs.shows[_show_id].num_votes_by_id[_entry_id];
    }
}