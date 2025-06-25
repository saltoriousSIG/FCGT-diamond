// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0; 
import "@solidstate/contracts/access/ownable/Ownable.sol";
import "@solidstate/contracts/security/reentrancy_guard/ReentrancyGuard.sol";
import "../libraries/LibTalentDiamond.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AirdropFacet is Ownable, ReentrancyGuard { 
    event AirdropClaimed (address indexed user_address, uint256 amount);

    function calculateAirdrop(uint256 _show_id) public onlyOwner { 
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        LibTalentDiamond.TalentBaseStorage storage tbs = LibTalentDiamond.getTalentBaseStorage();
        LibTalentDiamond.AirdropStorage storage ads = LibTalentDiamond.getAirdropStorage();

        require (gs.shows[_show_id].state == LibTalentDiamond.ShowState.CLOSED, "Show not closed");
        LibTalentDiamond.Show storage current_show = gs.shows[_show_id];
        uint256 tlnt_balance = IERC20(tbs.TALENT_TOKEN).balanceOf(address(this));
        uint256 tlnt_to_voters = (tlnt_balance * 3500) / 10000;
        uint256 tlnt_to_submitters = (tlnt_balance * 3000) / 10000;
        uint256 tlnt_to_owner = (tlnt_balance * 1500) / 10000;
        uint256 tlnt_to_burn = (tlnt_balance * 2000) / 10000;
        uint256 total_voters = current_show.voters.length;
        uint256 total_submitters = current_show.participants.length;

        IERC20(tbs.TALENT_TOKEN).transfer(owner(), tlnt_to_owner);
        IERC20(tbs.TALENT_TOKEN).transfer(address(0), tlnt_to_burn);

        if (total_voters > 0) { 
            uint256 tlnt_per_voter = tlnt_to_voters / total_voters;
            for (uint256 i = 0; i < current_show.voters.length; i++) { 
                address voter = current_show.voters[i];
                ads.airdrop_balance_by_address[voter] += tlnt_per_voter;
            }
        }
        if (total_submitters > 0) { 
            uint256 tlnt_per_submitter = tlnt_to_submitters / total_submitters;

            for (uint256 i = 0; i < current_show.participants.length; i++) { 
                address submitter = current_show.participants[i];
                ads.airdrop_balance_by_address[submitter] += tlnt_per_submitter;
            }
        }
    }

    function claim_airdrop() public nonReentrant { 
        LibTalentDiamond.AirdropStorage storage ads = LibTalentDiamond.getAirdropStorage();
        LibTalentDiamond.TalentBaseStorage storage tbs = LibTalentDiamond.getTalentBaseStorage();
        uint256 balance = ads.airdrop_balance_by_address[msg.sender];
        require(balance > 0, "No airdrop available");
        IERC20 tlnt_token = IERC20(tbs.TALENT_TOKEN);
        ads.airdrop_balance_by_address[msg.sender] = 0;
        tlnt_token.transfer(msg.sender, balance);
        emit AirdropClaimed(msg.sender, balance);
    }

}