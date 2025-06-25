// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title IRemoveSubmissionFacet
 * @dev Interface for the RemoveSubmissionFacet contract
 */
interface IRemoveSubmissionFacet {
    /**
     * @dev Emitted when an entry is removed from a show
     * @param show_id The ID of the show from which the entry was removed
     * @param entry_id The ID of the entry that was removed
     * @param user_address The address of the user whose entry was removed
     */
    event EntryRemoved(uint256 show_id, string entry_id, address user_address);

    /**
     * @dev Removes a submission from a show and handles all cleanup
     * @param _show_id The ID of the show containing the submission to remove
     * @param _entry_id The ID of the entry to remove
     * @notice Only callable by the owner
     * @notice Uses reentrancy protection
     * @notice Show must be in STARTED state
     * @notice Removes participant from participants array
     * @notice Removes submission from submissions array
     * @notice Refunds all voters who voted for this entry
     * @notice Refunds the original submitter their entry fee
     * @notice Updates vote counts and prize pool accordingly
     * @notice Cleans up all mappings related to the removed entry
     */
    function remove_submission(uint256 _show_id, string calldata _entry_id) external;
}