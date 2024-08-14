// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0

pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract MusicFromNothing is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    // Votes
    mapping(address => mapping(string => uint256)) public battlesVotes;

    // Token price in wei (Ether units)
    uint256 public tokenPrice;

    // Events
    event Voted(address indexed userAddress, string battleId, uint256 amount);
    event TokensPurchased(address indexed buyer, uint256 amountSpent, uint256 amountReceived);
    event TokensDeposited(address indexed depositor, uint256 amount);
    event TokensSubtracted(address indexed user, uint256 amount);
    event EtherWithdrawn(address indexed owner, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner, string memory erc20name, string memory erc20symbol, uint256 initialTokenPrice) initializer public {
        __ERC20_init(erc20name, erc20symbol);
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        tokenPrice = initialTokenPrice; // Set initial token price
    }

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner whenNotPaused {
        _mint(to, amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20Upgradeable, ERC20PausableUpgradeable)
    {
        super._update(from, to, value);
    }

    // Function to vote with tokens
    function vote(string memory battleId, uint256 amount) external whenNotPaused {
        require(amount > 0, "Amount must be > 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient token balance");
        require(battlesVotes[msg.sender][battleId] == 0, "Already voted!");

        // Transfer tokens from the voter to the contract
        _transfer(msg.sender, address(this), amount);

        // Save voting information
        battlesVotes[msg.sender][battleId] = amount;

        // Emit event
        emit Voted(msg.sender, battleId, amount);
    }

    // Function to buy tokens with Ether
    function buyTokens() external payable whenNotPaused {
        require(msg.value > 0, "Ether sent must be greater than zero");

        uint256 amountToBuy = msg.value / tokenPrice; // Calculate the amount of tokens to buy
        require(amountToBuy > 0, "Amount to buy must be greater than zero");

        // Mint tokens and transfer them to the buyer
        _mint(msg.sender, amountToBuy);

        // Emit an event for the token purchase
        emit TokensPurchased(msg.sender, msg.value, amountToBuy);
    }

    // Function to deposit tokens into the contract
    function depositTokens(uint256 amount) public onlyOwner {
        require(balanceOf(msg.sender) >= amount, "Insufficient token balance");
        _transfer(msg.sender, address(this), amount);
        emit TokensDeposited(msg.sender, amount);
    }

    // Function to withdraw all Ether from the contract
    function withdrawAllEther() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No Ether available to withdraw");

        payable(owner()).transfer(contractBalance);
        emit EtherWithdrawn(owner(), contractBalance);
    }

    // Function to withdraw a specific amount of tokens from the contract
    function withdrawTokens(uint256 amount) public onlyOwner {
        require(balanceOf(address(this)) >= amount, "Insufficient token balance");
        _transfer(address(this), owner(), amount);
    }

    // Function to set the token price (in wei per token)
    function setTokenPrice(uint256 newPrice) public onlyOwner {
        tokenPrice = newPrice;
    }
}
