// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "../libraries/LibTalentDiamond.sol";

/**
 * @title ICastVoteFacet
 * @dev Interface for the CastVoteFacet contract
 */
interface ICastVoteFacet {
    /**
     * @dev Emitted when a vote is cast
     * @param show_id The ID of the show being voted on
     * @param entry_id The ID of the entry being voted for
     * @param user_address The address of the user casting the vote
     */
    event VoteCast(uint256 indexed show_id, string indexed entry_id, address indexed user_address);

    /**
     * @dev Casts a vote for a specific entry in a show
     * @param _show_id The ID of the show to vote in
     * @param _vote The vote data containing entry selection and currency type
     * @notice Uses reentrancy protection
     * @notice Limited to 3 votes per user per show
     * @notice Only one TLNT vote allowed per user per show
     * @notice Show must be in VOTING state
     * @notice Must be within the voting time window
     * @notice Requires payment in either TLNT or USDC tokens
     */
    function vote(uint256 _show_id, LibTalentDiamond.Vote calldata _vote) external;
}