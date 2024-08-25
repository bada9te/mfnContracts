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
    mapping(address => mapping(string => uint256)) public battlesVotes;

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

    function vote(string memory battleId, uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        require(token.balanceOf(msg.sender) >= amount, "Insufficient token balance");

        // Transfer tokens from the voter to the logic contract
        token.transferFrom(msg.sender, address(this), amount);

        // Save voting information
        battlesVotes[msg.sender][battleId] = amount;

        // Emit event
        emit Voted(msg.sender, battleId, amount);
    }

    function depositTokens(uint256 amount) public {
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

    function setToken(address tokenAddress) public onlyOwner {
        token = IERC20(tokenAddress);
        emit TokenAddressChanged(tokenAddress);
    }
}
