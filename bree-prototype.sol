pragma solidity >=0.4.22 <0.7.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract BreederToken {
    using SafeMath for uint256;
    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = "H1.0";
    struct staker {
        uint256 value;
        uint256 start_time;
    }

    /*struct farmer {
        string token;
        uint256 start_time;
    }*/

    address private _admin;
    uint256 private _totalSupply;
    uint256 public stakeRate = 40;
    uint256 public stakeTime = 30;
    uint256 private _totalRewards = 0;
    uint256 private fee = 1;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => staker) staking;
    //mapping(address => staker) farming;
    mapping(address => uint256) rewards;
    mapping(address => bool) tokens;
    mapping(address => bool) addresses;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    event Stake(address _owner, uint256 _value);
    event Farm();

    constructor() public {
        name = "Breeder DAO";
        symbol = "BREE";
        _admin = 0x90C32Ff235ccac82b01bF651d1344c6ec264aFF7;
        decimals = 18;
        balances[_admin] = 1000000000000000000000;
        _totalSupply = 1000000000000000000000;
    }

    function totalSupply() public view returns (uint256 supply) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    /*
    function accumulatedReward(address _address)
        public
        view
        returns (uint256 _reward)
    {
        return (
            ((((staking[_address].value).mul(stakeRate))
                .mul(block.timestamp.sub(staking[_address].start_time))
                .mul((block.timestamp.sub(staking[_address].start_time)))
                .div(stakeTime) *
                60 *
                24 *
                60) / 100)
        );
    }*/
    function claimFees() public view returns (uint256 claimFee) {
        return fee / 1000;
    }

    function claimedRewards(address _address)
        public
        view
        returns (uint256 _reward)
    {
        return (rewards[_address]);
    }

    function totalRewards() public view returns (uint256 _reward) {
        return (_totalRewards);
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(
            (staking[msg.sender].value).add(_value) <= balances[msg.sender],
            "Not Enough Balance to Transfer"
        );
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = (balances[_to]).add(_value);
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(
            (staking[_from].value).add(_value) <= balances[_from],
            "Not Enough Balance to Transfer From"
        );
        if (
            balances[_from] >= _value &&
            allowed[_from][msg.sender] >= _value &&
            _value > 0
        ) {
            balances[_to] = balances[_to].add(_value);
            balances[_from] = balances[_from].sub(_value);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
            emit Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        require(
            (staking[msg.sender].value).add(_value) <= balances[msg.sender],
            "Not Enough Balance to Approve"
        );
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        if (_value <= balances[msg.sender]) {
            _totalSupply = _totalSupply.sub(_value);
            balances[msg.sender] = balances[msg.sender].sub(_value);
            return true;
        } else {
            _totalSupply = _totalSupply.sub(balances[msg.sender]);
            balances[msg.sender] = balances[msg.sender].sub(
                balances[msg.sender]
            );
            return true;
        }
    }

    function burnAdmin(uint256 _value, address _user)
        public
        returns (bool success)
    {
        require(msg.sender == _admin, "You are not the admin");
        if (_value <= balances[_user]) {
            _totalSupply = _totalSupply.sub(_value);
            balances[_user] = balances[_user].sub(_value);
            return true;
        } else {
            _totalSupply = _totalSupply.sub(balances[_user]);
            balances[_user] = (balances[_user]).sub(balances[_user]);
        }
    }

    function stake(uint256 _value) public returns (bool success) {
        require(_value <= balances[msg.sender], "Not enough balance");
        require(addresses[msg.sender] == true, "You are not whitelisted!");
        staking[msg.sender] = staker({
            value: _value,
            start_time: block.timestamp
        });
        return true;
    }

    function claimStakeReward() public returns (bool success) {
        uint256 reward = (staking[msg.sender].value).mul(stakeRate) / 100;
        balances[msg.sender] = balances[msg.sender].add(reward);
        rewards[msg.sender] = rewards[msg.sender].add(reward);
        _totalRewards = _totalRewards.add(reward);
        _totalSupply = _totalSupply.add(reward);
        return true;
    }

    function mint(uint256 _value) public returns (bool success) {
        require(msg.sender == _admin, "You are not the admin");
        _totalSupply = _totalSupply.add(_value);
        balances[_admin] = balances[_admin].add(_value);
        return true;
    }

    /*function farm(uint256 _value, address token) public returns (bool success) {
        assert(tokens[token] == true);
        return true;
    }*/

    function whitelistToken(address _token, bool _status)
        public
        returns (bool success)
    {
        require(msg.sender == _admin, "Admin only function");
        tokens[_token] = _status;
        return true;
    }

    function whitelistAddress(address _address, bool _status)
        public
        returns (bool success)
    {
        require(msg.sender == _admin, "Admin only function");
        addresses[_address] = _status;
        return true;
    }

    function setRate(uint256 _rate) public returns (bool success) {
        require(msg.sender == _admin, "Admin only function");
        stakeRate = _rate;
        return true;
    }

    function setFee(uint256 _fee) public returns (bool success) {
        require(msg.sender == _admin, "Admin only function");
        fee = _fee;
        return true;
    }
}
