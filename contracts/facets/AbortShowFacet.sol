// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0; 
import "@solidstate/contracts/access/ownable/Ownable.sol";
import "../libraries/LibTalentDiamond.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AbortShowFacet is Ownable { 
    event ShowAborted(uint256 indexed showId, address indexed owner);

    function abortShow(uint256 _showId) public onlyOwner { 
        LibTalentDiamond.GameStorage storage gs = LibTalentDiamond.getGameStorage();
        LibTalentDiamond.TalentBaseStorage storage tbs = LibTalentDiamond.getTalentBaseStorage();
        LibTalentDiamond.Show storage show = gs.shows[_showId];
        require(show.state == LibTalentDiamond.ShowState.VOTING, "Show is not in voting state");

        address[] memory participants = show.participants;
        uint256 refundAmount = tbs.token_entry_price;   

        for (uint256 i = 0; i < participants.length; i++) {
            address participant = participants[i];
            IERC20(tbs.USDC_TOKEN).transfer(participant, refundAmount);
        }

       LibTalentDiamond.Vote[] memory votes = show.votes;
        uint256 voteRefundAmount = tbs.vote_price;

        for (uint256 i = 0; i < votes.length; i++) {
            LibTalentDiamond.Vote memory vote = votes[i];
            if (vote.vote_currency == LibTalentDiamond.VoteCurrency.TLNT) {
                IERC20(tbs.TALENT_TOKEN).transfer(vote.voter_address, voteRefundAmount);
            } else {
                IERC20(tbs.USDC_TOKEN).transfer(vote.voter_address, voteRefundAmount);
            }
        }

        show.state = LibTalentDiamond.ShowState.CLOSED;
        emit ShowAborted(_showId, msg.sender);
    }
}
