// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title IFinalizeFacet
 * @dev Interface for the FinalizeFacet contract
 */
interface IFinalizeFacet {
    /**
     * @dev Emitted when a show is finalized
     * @param show_id The ID of the show that was finalized
     */
    event ShowFinalized(uint256 indexed show_id);

    /**
     * @dev Finalizes a show by determining winners and distributing prizes
     * @param _show_id The ID of the show to finalize
     * @notice Only callable by the owner
     * @notice Show must be in VOTING state
     * @notice Voting period must be closed (past voting_closed_time)
     * @notice Calculates top 3 winners based on vote counts
     * @notice Distributes USDC prizes according to placement percentages
     * @notice Takes platform fee and performs token buyback
     * @notice Changes show state to CLOSED after completion
     */
    function finalize(uint256 _show_id) external;
}