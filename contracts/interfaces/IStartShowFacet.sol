// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title IStartShowFacet
 * @dev Interface for the StartShowFacet contract
 */
interface IStartShowFacet {
    /**
     * @dev Emitted when a new show is started
     * @param show_id The ID of the newly started show
     * @param start_time The timestamp when the show starts
     * @param entry_closed_time The timestamp when entry submission closes
     * @param voting_closed_time The timestamp when voting closes
     */
    event ShowStarted(uint256 indexed show_id, uint256 start_time, uint256 entry_closed_time, uint256 voting_closed_time);

    /**
     * @dev Starts a new show with specified parameters
     * @param _start_time The timestamp when the show should start
     * @param _entry_closed_time The timestamp when entry submissions should close
     * @param _voting_closed_time The timestamp when voting should close
     * @param name The name of the show
     * @param description The description of the show
     * @param tags Tags associated with the show
     * @notice Only callable by the owner
     * @notice Sets the show state to STARTED
     * @notice Increments the current_show_id counter for the next show
     * @notice Emits ShowStarted event with show details
     */
    function startShow(
        uint256 _start_time, 
        uint256 _entry_closed_time, 
        uint256 _voting_closed_time, 
        string calldata name, 
        string calldata description, 
        string calldata tags
    ) external;
}