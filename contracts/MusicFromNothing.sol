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
    // votes
    mapping(address => mapping(string => uint)) battlesVotes;
    
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner, string memory erc20name, string memory erc20symbol) initializer public {
        __ERC20_init(erc20name, erc20symbol);
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
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

    // The following functions are overrides required by Solidity.
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20Upgradeable, ERC20PausableUpgradeable)
    {
        super._update(from, to, value);
    }

    // BATTLES
    event Voted(address userAddress, string battleId, uint256 amount);

    function vote(string memory battleId) external payable whenNotPaused {
        // amount must be > 0
        require(msg.value > 0, "Amount must be > 0");

        // check if the user is already voted
        require(battlesVotes[msg.sender][battleId] == 0, "Already voted!");

        // save voting
        battlesVotes[msg.sender][battleId] = msg.value;

        // transfer to the owner
        address payable withdrawalAddress = payable(owner());
        withdrawalAddress.transfer(msg.value);

        emit Voted(msg.sender, battleId, msg.value);
    } 

}