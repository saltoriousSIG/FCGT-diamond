// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;
/**
 * @title IAirdropFacet
 * @dev Interface for the AirdropFacet contract
 */
interface IAirdropFacet {
    /**
     * @dev Emitted when an airdrop is claimed by a user
     * @param user_address The address of the user claiming the airdrop
     * @param amount The amount of tokens claimed
     */
    event AirdropClaimed(address indexed user_address, uint256 amount);

    /**
     * @dev Calculates and distributes airdrop tokens for a closed show
     * @param _show_id The ID of the show to calculate airdrop for
     * @notice Only callable by the owner
     * @notice The show must be in CLOSED state
     */
    function calculateAirdrop(uint256 _show_id) external;

    /**
     * @dev Allows users to claim their allocated airdrop tokens
     * @notice Uses reentrancy protection
     * @notice Requires the caller to have a positive airdrop balance
     */
    function claim_airdrop() external;
}