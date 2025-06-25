// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "../libraries/LibTalentDiamond.sol";

/**
 * @title IUtilitiesFacet
 * @dev Interface for the UtilitiesFacet contract - administrative functions for system configuration
 */
interface IUtilitiesFacet {
    /**
     * @dev Emitted when a show's state is updated
     * @param show_id The ID of the show whose state was updated
     * @param state The new state of the show
     */
    event ShowStateUpdated(uint256 indexed show_id, LibTalentDiamond.ShowState state);

    /**
     * @dev Updates the TALENT token contract address
     * @param _new_talent_token The new TALENT token contract address
     * @notice Only callable by the owner
     */
    function updateTalentToken(address _new_talent_token) external;

    /**
     * @dev Updates the USDC token contract address
     * @param _new_usdc_token The new USDC token contract address
     * @notice Only callable by the owner
     */
    function updateUSDCToken(address _new_usdc_token) external;

    /**
     * @dev Updates the entry fee price for submissions
     * @param _new_price The new entry price in tokens
     * @notice Only callable by the owner
     */
    function updateTokenEntryPrice(uint256 _new_price) external;

    /**
     * @dev Updates the vote reward amount
     * @param _new_reward The new vote reward amount
     * @notice Only callable by the owner
     */
    function updateVoteReward(uint256 _new_reward) external;

    /**
     * @dev Updates the price required to cast a vote
     * @param _new_vote_price The new vote price in tokens
     * @notice Only callable by the owner
     */
    function updateVotePrice(uint256 _new_vote_price) external;

    /**
     * @dev Updates the platform fee percentage for shows
     * @param _show_percentage The new platform fee percentage (in basis points, e.g., 1000 = 10%)
     * @notice Only callable by the owner
     */
    function updateShowPercentage(uint256 _show_percentage) external;

    /**
     * @dev Updates the metadata for an existing show
     * @param _show_id The ID of the show to update
     * @param name The new name for the show
     * @param description The new description for the show
     * @param tags The new tags for the show
     * @notice Only callable by the owner
     * @notice Show ID must be valid (between 1 and current_show_id)
     */
    function updateShowData(
        uint256 _show_id, 
        string calldata name, 
        string calldata description, 
        string calldata tags
    ) external;

    /**
     * @dev Updates the prize distribution percentages for winners
     * @param _winner_percentage The percentage for first place (in basis points)
     * @param _second_percentage The percentage for second place (in basis points)
     * @param _third_percentage The percentage for third place (in basis points)
     * @notice Only callable by the owner
     * @notice All percentages must sum to 10000 (100%)
     */
    function updateWinningPercentages(
        uint256 _winner_percentage, 
        uint256 _second_percentage, 
        uint256 _third_percentage
    ) external;

    /**
     * @dev Manually updates the state of a show
     * @param _show_id The ID of the show to update
     * @param _show_state The new state to set for the show
     * @notice Only callable by the owner
     * @notice Emits ShowStateUpdated event
     */
    function updateShowState(uint256 _show_id, LibTalentDiamond.ShowState _show_state) external;
}