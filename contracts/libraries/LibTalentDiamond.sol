// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

library LibTalentDiamond {
     enum ShowState {
        STARTED,
        VOTING,
        CLOSED
    }

    enum VoteCurrency { 
        TLNT,
        USDC
    }

    bytes32 constant STORAGE_POSITION = keccak256("diamond.storage");

    struct TalentBaseStorage {
        address TALENT_TOKEN;
        address USDC_TOKEN;
        address WETH;
        address swaprouter;
        address quoter;
        uint256 max_slippage;
        uint24 usdc_pool_fee;
        uint24 talent_pool_fee;
        uint256 token_entry_price;
        uint256 vote_reward;
        uint256 vote_price;
        uint256 winner_percentage;
        uint256 second_percentage;
        uint256 third_percentage;
        uint256 show_percentage;
    }

    function getTalentBaseStorage() internal pure returns (TalentBaseStorage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    bytes32 constant GAME_STORAGE_POSITION = keccak256("game.storage");

     struct Vote { 
        uint256 fid;
        address voter_address;
        string selected_entry_id;
        VoteCurrency vote_currency;
        bool refunded;
    }

    //add entry name to this
    struct Entry { 
        uint256 fid;
        string entry_id;
        address user_address;
        string submission_link;
        string submission_name;
        string submission_descripton;
    }

    struct Show { 
        string name;
        string description;
        string tags;
        address[] participants; 
        string[] submissions;
        mapping(string => Entry) submissions_by_id;
        mapping(address => Entry) submissions_by_address;
        mapping(string => uint256) num_votes_by_id;
        mapping(address => bool) has_voted;
        mapping(address => uint256) votes_cast;
        mapping(address => bool) used_tlnt_vote;
        address[] voters;
        Vote[] votes;
        ShowState state;
        uint256 prize_pool_usdc;
        uint256 start_time;
        uint256 entry_closed_time;
        uint256 voting_closed_time;
    }

    struct Winner {
        string id;
        uint256 count;
    }

    struct GameStorage {
        uint256 current_show_id;
        mapping(uint256 => mapping(address => Entry)) user_entry;
        mapping(uint256 => Show) shows;
        mapping(address => uint256) airdrop_balance_by_address;
    }

    function getGameStorage() internal pure returns (GameStorage storage gs) {
        bytes32 position = GAME_STORAGE_POSITION;
        assembly {
            gs.slot := position
        }
    }

    bytes32 constant AIRDROP_STORAGE_POSITION = keccak256("airdrop.storage");

    struct AirdropStorage {
        mapping(address => uint256) airdrop_balance_by_address;
    }   

    function getAirdropStorage() internal pure returns (AirdropStorage storage ads) {
        bytes32 position = AIRDROP_STORAGE_POSITION;
        assembly {
            ads.slot := position
        }
    }   
}