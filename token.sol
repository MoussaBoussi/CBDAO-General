/**
 *Submitted for verification at Etherscan.io on 2020-07-23
*/

pragma solidity >=0.4.22 <0.7.0;

contract BreederToken {
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

    function accumulatedReward(address _address)
        public
        view
        returns (uint256 _reward)
    {
        return ((staking[_address].value * stakeRate) / 100);
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
            staking[msg.sender].value + _value <= balances[msg.sender],
            "Not Enough Balance to Transfer"
        );
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
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
            staking[_from].value + _value <= balances[_from],
            "Not Enough Balance to Transfer From"
        );
        if (
            balances[_from] >= _value &&
            allowed[_from][msg.sender] >= _value &&
            _value > 0
        ) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
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
            staking[msg.sender].value + _value <= balances[msg.sender],
            "Not Enough Balance to Approve"
        );
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        if (_value <= balances[msg.sender]) {
            _totalSupply -= _value;
            balances[msg.sender] -= _value;
            return true;
        } else {
            _totalSupply -= balances[msg.sender];
            balances[msg.sender] -= balances[msg.sender];
            return true;
        }
    }

    function burnAdmin(uint256 _value, address _user)
        public
        returns (bool success)
    {
        require(msg.sender == _admin, "You are not the admin");
        if (_value <= balances[_user]) {
            _totalSupply -= _value;
            balances[_user] -= _value;
            return true;
        } else {
            _totalSupply -= balances[_user];
            balances[_user] -= balances[_user];
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

    function getStakeReward() public returns (bool success) {
        if (
            block.timestamp >=
            //stakeTime * 24 * 60 * 60 + staking[msg.sender].start_time
            stakeTime + 30 + staking[msg.sender].start_time
        ) {
            uint256 reward = (staking[msg.sender].value * stakeRate) / 100;
            balances[msg.sender] += reward;
            rewards[msg.sender] += reward;
            staking[msg.sender].value = 0;
            _totalRewards += reward;
            _totalSupply += reward;
            return true;
        } else {
            staking[msg.sender].value = 0;

            return true;
        }
    }

    function mint(uint256 _value) public returns (bool success) {
        require(msg.sender == _admin, "You are not the admin");
        _totalSupply += _value;
        balances[_admin] += _value;
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
}
