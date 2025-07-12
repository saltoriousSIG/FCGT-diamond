// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title IAbortShowFacet
 * @dev Interface for the AbortShowFacet contract
 * @notice This interface defines the functions for aborting shows and handling refunds
 */
interface IAbortShowFacet {
    
    /**
     * @dev Emitted when a show is aborted
     * @param showId The unique identifier of the aborted show
     * @param owner The address of the owner who aborted the show
     */
    event ShowAborted(uint256 indexed showId, address indexed owner);
    
    /**
     * @dev Aborts a show that is currently in voting state
     * @notice Only the contract owner can call this function
     * @notice Refunds entry fees to all participants and vote fees to all voters
     * @notice Changes the show state to CLOSED
     * @param _showId The unique identifier of the show to abort
     * 
     * Requirements:
     * - Caller must be the contract owner
     * - Show must be in VOTING state
     * - Contract must have sufficient token balances for refunds
     * 
     * Effects:
     * - Refunds token_entry_price in USDC to each participant
     * - Refunds vote_price in the respective currency (TLNT or USDC) to each voter
     * - Sets show state to CLOSED
     * - Emits ShowAborted event
     */
    function abortShow(uint256 _showId) external;
}