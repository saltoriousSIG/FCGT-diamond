// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "../libraries/LibTalentDiamond.sol";

/**
 * @title IDataFacet
 * @dev Interface for the DataFacet contract - provides read-only access to show data
 */
interface IDataFacet {
    /**
     * @dev Struct containing comprehensive show data
     */
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

    /**
     * @dev Fetches comprehensive data for a specific show
     * @param _show_id The ID of the show to fetch data for
     * @return show_data Complete show information including participants, votes, and metadata
     */
    function fetch_show_data(uint256 _show_id) external view returns(ShowDataResponse memory show_data);

    /**
     * @dev Fetches all submissions for a specific show
     * @param _show_id The ID of the show to fetch submissions for
     * @return submissions Array of all entries submitted to the show
     */
    function fetch_submissions(uint256 _show_id) external view returns(LibTalentDiamond.Entry[] memory submissions);

    /**
     * @dev Fetches the entry submitted by a specific user for a show
     * @param _show_id The ID of the show
     * @param _user The address of the user whose entry to fetch
     * @return submission The entry submitted by the specified user
     */
    function fetch_entry_by_address(uint256 _show_id, address _user) external view returns(LibTalentDiamond.Entry memory submission);

    /**
     * @dev Fetches the number of votes cast by a specific user in a show
     * @param _show_id The ID of the show
     * @param _user The address of the user
     * @return num_votes_cast The number of votes the user has cast in the show
     */
    function fetch_num_votes_cast_by_address(uint256 _show_id, address _user) external view returns(uint256 num_votes_cast);
}