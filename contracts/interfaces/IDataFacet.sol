// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "../libraries/LibTalentDiamond.sol";

interface IDataFacet {
    struct ShowDataResponse {
        address[] participants;
        string[] submissions;
        LibTalentDiamond.Vote[] votes;
        LibTalentDiamond.ShowState state;
        uint256 prize_pool_usdc;
        uint256 start_time;
        uint256 entry_closed_time;
        uint256 voting_closed_time;
        string name;
        string description;
        string tags;
        address[] voters;
    }

    function fetch_show_data(uint256 _show_id) external view returns(ShowDataResponse memory show_data);
    
    function fetch_base_data() external pure returns(LibTalentDiamond.TalentBaseStorage memory base_data);
    
    function fetch_submissions(uint256 _show_id) external view returns(LibTalentDiamond.Entry[] memory submissions);
    
    function fetch_submission_by_id(uint256 _show_id, string calldata _entry_id) external view returns (LibTalentDiamond.Entry memory entry);
    
    function fetch_entry_by_address(uint256 _show_id, address _user) external view returns(LibTalentDiamond.Entry memory submission);
    
    function fetch_num_votes_cast_by_address(uint256 _show_id, address _user) external view returns(uint256 num_votes_cast);
    
    function fetch_current_show_id() external view returns(uint256 id);
    
    function fetch_votes_by_entry_id(uint256 _show_id, string calldata _entry_id) external view returns(LibTalentDiamond.Vote[] memory vote);
    
    function fetch_num_votes_by_entry_id(uint256 _show_id, string calldata _entry_id) external view returns(uint256 num_votes);
}