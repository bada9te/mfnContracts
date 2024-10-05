// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0

pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract MusicFromNothing is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    IERC20 public token;

    // Votes
    mapping(string => bool) public battleExists;
    mapping(string => uint64) public battleFinishesAt;
    mapping(string => string[]) public postsRelations;
    //      sender           battleId           postId     amount
    mapping(address => mapping(string => mapping(string => uint256))) public battleTokensTransfers;

    // Track the total tokens per post in a battle
    mapping(string => mapping(string => uint256)) public totalTokensPerPost;
    // Track the total votings per post
    mapping(string => mapping(string => uint256)) public totalVotingsPerPost;

    // Events
    event Voted(address indexed userAddress, string battleId, uint256 amount);
    event TokensDeposited(address indexed depositor, uint256 amount);
    event TokensSubtracted(address indexed user, uint256 amount);
    event EtherWithdrawn(address indexed owner, uint256 amount);
    event TokenAddressChanged(address newAddress);

    function initialize(address initialOwner, address tokenAddress) initializer public {
        __Ownable_init(initialOwner);
        token = IERC20(tokenAddress);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function createBattle(
        string memory battleId, 
        string memory post1Id,
        string memory post2Id,
        uint64 hoursBeforeFinish
    ) public {
        uint64 endsAt = uint64(block.timestamp + (hoursBeforeFinish * 3600));
        battleFinishesAt[battleId] = endsAt;
        postsRelations[battleId] = [post1Id, post2Id];
        battleExists[battleId] = true;
    }

    function vote(string memory battleId, string memory postId, uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        require(token.balanceOf(msg.sender) >= amount, "Insufficient token balance");

        // Transfer tokens from the voter to the logic contract
        token.transferFrom(msg.sender, address(this), amount);

        // Save voting information
        battleTokensTransfers[msg.sender][battleId][postId] += amount;

        // Update total tokens and votings for the specific post
        totalTokensPerPost[battleId][postId] += amount;
        totalVotingsPerPost[battleId][postId] += 1;

        // Emit event
        emit Voted(msg.sender, battleId, amount);
    }

    function depositTokens(uint256 amount) public {
        require(token.balanceOf(msg.sender) >= amount, "Insufficient token balance");
        token.transferFrom(msg.sender, address(this), amount);
        emit TokensDeposited(msg.sender, amount);
    }

    function calculateWithdrawalTokensFromBattle(
        string memory battleId,
        address user
    ) public view returns (uint256 totalWithdrawalPerPost1, uint256 totalWithdrawalPerPost2) {
        string[] memory posts = postsRelations[battleId];

        if (battleTokensTransfers[user][battleId][posts[0]] == 0) {
            totalWithdrawalPerPost1 = 0;
        } else {
            // Calculate the bonus from the total tokens on the losing side
            uint256 userTokens = battleTokensTransfers[user][battleId][posts[0]];
            uint256 totalTokensLosingPost = totalTokensPerPost[battleId][posts[1]];
            
            // Bonus is calculated from the total tokens of the losing post
            uint256 bonus = 0;
            if (totalVotingsPerPost[battleId][posts[0]] > 0) {
                bonus = totalTokensLosingPost / totalVotingsPerPost[battleId][posts[0]];
            }

            // Total amount to withdraw is user's tokens + bonus
            totalWithdrawalPerPost1 = userTokens + bonus;
        }

        if (battleTokensTransfers[user][battleId][posts[1]] == 0) {
            totalWithdrawalPerPost2 = 0;
        } else {
            // Calculate the bonus from the total tokens on the losing side
            uint256 userTokens = battleTokensTransfers[user][battleId][posts[1]];
            uint256 totalTokensLosingPost = totalTokensPerPost[battleId][posts[0]];
            

            // Bonus is calculated from the total tokens of the losing post
            uint256 bonus = 0;
            if (totalVotingsPerPost[battleId][posts[1]] > 0) {
                bonus = totalTokensLosingPost / totalVotingsPerPost[battleId][posts[1]];
            }

            // Total amount to withdraw is user's tokens + bonus
            totalWithdrawalPerPost2 = userTokens + bonus;
        }
    }

    function withdrawTokensFromBattle(
        string memory battleId, 
        string memory postId
    ) public {
        require(battleFinishesAt[battleId] < block.timestamp, "Battle is not finished yet");
        require(battleTokensTransfers[msg.sender][battleId][postId] > 0, "No tokens available to withdraw");

        // Determine the winning and losing posts
        string[] memory posts = postsRelations[battleId];
        string memory winningPostId = totalTokensPerPost[battleId][posts[0]] >= totalTokensPerPost[battleId][posts[1]]
            ? posts[0]
            : posts[1];
        string memory losingPostId = keccak256(abi.encodePacked(winningPostId)) == keccak256(abi.encodePacked(posts[0]))
            ? posts[1]
            : posts[0];

        // Check if the user voted for the winning post
        require(keccak256(abi.encodePacked(postId)) == keccak256(abi.encodePacked(winningPostId)), "Only the winner can claim tokens");

        // Calculate the bonus from the total tokens on the losing side
        uint256 userTokens = battleTokensTransfers[msg.sender][battleId][postId];
        uint256 totalTokensLosingPost = totalTokensPerPost[battleId][losingPostId];

        // Bonus is calculated from the total tokens of the losing post
        uint256 bonus = 0;
        if (totalVotingsPerPost[battleId][winningPostId] > 0) {
            bonus = totalTokensLosingPost / totalVotingsPerPost[battleId][winningPostId];
        }

        // Total amount to withdraw is user's tokens + bonus
        uint256 totalWithdrawal = userTokens + bonus;

        // Transfer the tokens back to the user
        token.transfer(msg.sender, totalWithdrawal);
    }

    function withdrawAllEther() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No Ether available to withdraw");

        payable(owner()).transfer(contractBalance);
        emit EtherWithdrawn(owner(), contractBalance);
    }

    function withdrawTokens(uint256 amount) public onlyOwner {
        require(token.balanceOf(address(this)) >= amount, "Insufficient token balance");
        token.transfer(owner(), amount);
    }

    function setToken(address tokenAddress) public onlyOwner {
        token = IERC20(tokenAddress);
        emit TokenAddressChanged(tokenAddress);
    }
}
