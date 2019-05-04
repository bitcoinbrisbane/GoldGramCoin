pragma solidity 0.5.0;

interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; 
}

contract GGCToken_New { 
    // Semi Standard ERC-20 Token Contract:
    address public owner;
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    struct account {
        uint256 balance;
        bool isWhitelisted;
    }
    mapping (address => account) public accInfo;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed from, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Whitelist(address indexed from);
    event Blacklist(address indexed from);

    modifier onlyBy(address _account) {
        require( msg.sender == _account, "Sender not authorized.");
        _;
    }

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor(
    ) public {
        owner = msg.sender;                         // Make the creator the owner
        totalSupply = 0 * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        accInfo[msg.sender].balance = totalSupply;  // Give the creator all initial tokens
        accInfo[msg.sender].isWhitelisted = true;   // Give the creator whitelist privileges
        name = 'GGC Token';                         // Set the name for display purposes
        symbol = 'GGC';                             // Set the symbol for display purposes
    }

    /**
     * Change Contract Owner
     */
    function changeOwner(address _newOwner) external onlyBy(owner) {
        owner = _newOwner;
    }

    /**
     * Whitelist account address
     */
    function whitelist(address _account) external onlyBy(owner) {
        accInfo[_account].isWhitelisted = true;
        emit Whitelist(_account);
    }

    /**
     * Blacklist account address
     */
    function blacklist(address _account) external onlyBy(owner) {
        accInfo[_account].isWhitelisted = false;
        emit Blacklist(_account);
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        require(accInfo[_from].isWhitelisted == true);                               // Check if the sender is whitelisted
        require(accInfo[_from].balance >= _value);                                  // Check if the sender has enough
        require(accInfo[_to].isWhitelisted == true);                                 // Check if the receiver is whitelisted
        require(accInfo[_to].balance + _value >= accInfo[_to].balance);            // Check for overflows
        accInfo[_from].balance -= _value;                                           // Subtract from the sender
        accInfo[_to].balance += _value;                                             // Add the same to the recipient
        emit Transfer(_from, _to, _value);                                         // Emits a Transfer Event
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) external returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * Buy tokens
     *
     * Add `_value` tokens to the system irreversibly
     *
     * @param _value the amount of money to buy
     * @param _buyer the address of the Buyer
     */
    function buy(uint256 _value, address _buyer) onlyBy(owner) external returns (bool success) {
        require(accInfo[_buyer].isWhitelisted == true);   // Check if the buyer is whitelisted
        totalSupply += _value;                            // Updates totalSupply
        accInfo[_buyer].balance += _value;               // Updates Buyer Account
        emit Mint(msg.sender, _value);                    // Emits a Mint Event         
        return true;
    }

    /**
     * Sell tokens
     *
     * Remove `_value` tokens to the system irreversibly
     *
     * @param _value the amount of money to sell
     * @param _seller the address of the Seller
     */
    function sell(uint256 _value, address _seller) onlyBy(owner) external returns (bool success) {
        require(accInfo[_seller].isWhitelisted == true);   // Check if the seller is whitelisted
        require(accInfo[_seller].balance >= _value);      // Check if the account has enough
        totalSupply -= _value;                             // Updates totalSupply
        _burnFor(_value, _seller);                        // Updates Seller Account
        return true;
    }

    /**
     * Destroy tokens of Another Account
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     * @param _for the address of the owner of the tokens to burn
     */
    function _burnFor(uint256 _value, address _for) onlyBy(owner) internal returns (bool success) {
        accInfo[_for].balance -= _value;            // Subtract from the sender
        emit Burn(_for, _value);
        return true;
    }

    /**
     * Kill Smart Contract 
     *
     * Can only be called by contract Owner
     */
    function kill() public onlyBy(owner) {
        selfdestruct(msg.sender);
    }
}