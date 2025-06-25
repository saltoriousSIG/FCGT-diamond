// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "../libraries/LibTalentDiamond.sol";

/**
 * @title ISubmitEntryFacet
 * @dev Interface for the SubmitEntryFacet contract
 */
interface ISubmitEntryFacet {
    /**
     * @dev Emitted when an entry is submitted to a show
     * @param show_id The ID of the show the entry was submitted to
     * @param entry_id The unique ID of the submitted entry
     * @param user_address The address of the user who submitted the entry
     */
    event EntrySubmitted(uint256 indexed show_id, string entry_id, address user_address);

    /**
     * @dev Submits an entry to a show
     * @param _show_id The ID of the show to submit the entry to
     * @param entry The entry data containing all submission details
     * @notice Show must be in STARTED state
     * @notice Must be within the submission time window (after start_time, before entry_closed_time)
     * @notice Entry ID must be unique within the show
     * @notice User can only submit one entry per show
     * @notice Requires payment of entry fee in USDC tokens
     * @notice Adds user to participants list and increases prize pool
     * @notice Stores entry in multiple mappings for efficient access
     */
    function submit_entry(uint256 _show_id, LibTalentDiamond.Entry calldata entry) external;
} 