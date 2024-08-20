// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0

pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./MFNToken.sol";

contract MusicFromNothing is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    MFNToken public token;
    uint256 public tokenPrice; // Token price in wei (Ether units)

    // Votes
    mapping(address => mapping(string => uint256)) public battlesVotes;

    // Events
    event Voted(address indexed userAddress, string battleId, uint256 amount);
    event TokensPurchased(address indexed buyer, uint256 amountSpent, uint256 amountReceived);
    event TokensDeposited(address indexed depositor, uint256 amount);
    event TokensSubtracted(address indexed user, uint256 amount);
    event EtherWithdrawn(address indexed owner, uint256 amount);

    function initialize(address initialOwner, address tokenAddress, uint256 initialTokenPrice) initializer public {
        __Ownable_init(initialOwner);
        token = MFNToken(tokenAddress);
        tokenPrice = initialTokenPrice; // Set initial token price
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function vote(string memory battleId, uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        require(token.balanceOf(msg.sender) >= amount, "Insufficient token balance");
        require(battlesVotes[msg.sender][battleId] == 0, "Already voted!");

        // Transfer tokens from the voter to the logic contract
        token.transferFrom(msg.sender, address(this), amount);

        // Save voting information
        battlesVotes[msg.sender][battleId] = amount;

        // Emit event
        emit Voted(msg.sender, battleId, amount);
    }

    function buyTokens() external payable {
        require(msg.value > 0, "Ether sent must be greater than zero");

        uint256 amountToBuy = msg.value / tokenPrice; // Calculate the amount of tokens to buy
        require(amountToBuy > 0, "Amount to buy must be greater than zero");

        // Mint tokens and transfer them to the buyer
        token.mint(msg.sender, amountToBuy);

        // Emit an event for the token purchase
        emit TokensPurchased(msg.sender, msg.value, amountToBuy);
    }

    function depositTokens(uint256 amount) public onlyOwner {
        require(token.balanceOf(msg.sender) >= amount, "Insufficient token balance");
        token.transferFrom(msg.sender, address(this), amount);
        emit TokensDeposited(msg.sender, amount);
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

    function setTokenPrice(uint256 newPrice) public onlyOwner {
        tokenPrice = newPrice;
    }
}
