pragma solidity =0.6.6;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeSwapRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external  returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) 
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
}

contract ZethyrPancakeSwap {
    address public owner;
    IPancakeSwapRouter public cPSwapRouter;
    modifier onlyOwner()
    {
        require(msg.sender == owner, 'onlyOwner');
        _;
    }
    modifier dontAllowOtherContractAction() {
        require(tx.origin == msg.sender, 'ZPancakeSwap::00');
        _;
    }
    // ----------------------------------------------------------------------------
    // CONSTRUCTOR
    // ----------------------------------------------------------------------------
    constructor(
        address _cPSwapRouterAddr
        ) public {
        owner = msg.sender;
        IPancakeSwapRouter contractInterface = IPancakeSwapRouter(_cPSwapRouterAddr);
        cPSwapRouter = contractInterface;
    }

      /**
    * Action::manualApproveTransfer
    */
    function manualApproveTransfer(address _tokenAddr, address _spender) public onlyOwner returns(bool) {
        return IBEP20(_tokenAddr).approve(_spender, uint(-1));
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external dontAllowOtherContractAction returns (uint[] memory amounts) {

        require(amountIn > 0, 'ZPancakeSwap::01:01');
        require(amountOutMin > 0, 'ZPancakeSwap::01:02');
        require(path.length == 2, 'ZPancakeSwap::01:03');
        require(path[0] != address(0) && path[1] != address(0), 'ZPancakeSwap::01:04');
        require(path[0] != to && path[1] != to, 'ZPancakeSwap::01:05');
        require(IBEP20(path[0]).balanceOf(msg.sender) >= amountIn, 'ZPancakeSwap::01:06');
        // get Token
        IBEP20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        
        return cPSwapRouter.swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
    }
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external dontAllowOtherContractAction returns (uint[] memory amounts) {

        require(amountOut > 0, 'ZPancakeSwap::02:01');
        require(amountInMax > 0, 'ZPancakeSwap::02:02');
        require(path.length == 2, 'ZPancakeSwap::02:03');
        require(path[0] != address(0) && path[1] != address(0), 'ZPancakeSwap::02:04');
        require(path[0] != to && path[1] != to, 'ZPancakeSwap::02:05');
        require(IBEP20(path[0]).balanceOf(msg.sender) >= amountInMax, 'ZPancakeSwap::02:06');
        // get Token        
        IBEP20(path[0]).transferFrom(msg.sender, address(this), amountInMax);
        
        return cPSwapRouter.swapTokensForExactTokens(amountOut, amountInMax, path, to, deadline);
    }
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        dontAllowOtherContractAction
        payable
        returns (uint[] memory amounts)
    {
        require(amountOutMin > 0, 'ZPancakeSwap::03:01');
        require(msg.value > 0, 'ZPancakeSwap::03:02');
        require(path.length == 2, 'ZPancakeSwap::03:03');
        require(path[0] != address(0) && path[1] != address(0), 'ZPancakeSwap::03:04');
        require(path[0] != to && path[1] != to, 'ZPancakeSwap::03:05');
        // get Token     
        return cPSwapRouter.swapExactETHForTokens{ value: msg.value }(amountOutMin, path, to, deadline);   
    }
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        dontAllowOtherContractAction
        returns (uint[] memory amounts)
    {
        require(amountOut > 0, 'ZPancakeSwap::04:01');
        require(amountInMax > 0, 'ZPancakeSwap::04:02');
        require(path.length == 2, 'ZPancakeSwap::04:03');
        require(path[0] != address(0) && path[1] != address(0), 'ZPancakeSwap::04:04');
        require(path[0] != to && path[1] != to, 'ZPancakeSwap::04:05');
        require(IBEP20(path[0]).balanceOf(msg.sender) >= amountInMax, 'ZPancakeSwap::04:06');
        // get Token        
        IBEP20(path[0]).transferFrom(msg.sender, address(this), amountInMax);
        
        return cPSwapRouter.swapTokensForExactETH(amountOut, amountInMax, path, to, deadline);
    }
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) 
        external
        dontAllowOtherContractAction
        returns (uint[] memory amounts)
    {

        require(amountOutMin > 0, 'ZPancakeSwap::05:01');
        require(amountIn > 0, 'ZPancakeSwap::05:02');
        require(path.length == 2, 'ZPancakeSwap::05:03');
        require(path[0] != address(0) && path[1] != address(0), 'ZPancakeSwap::05:04');
        require(path[0] != to && path[1] != to, 'ZPancakeSwap::05:05');
        require(IBEP20(path[0]).balanceOf(msg.sender) >= amountIn, 'ZPancakeSwap::05:06');
        // get Token        
        IBEP20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        
        return cPSwapRouter.swapExactTokensForETH(amountIn, amountOutMin, path, to, deadline);
    }
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        dontAllowOtherContractAction
        payable
        returns (uint[] memory amounts)
    {
        require(amountOut > 0, 'ZPancakeSwap::06:01');
        require(msg.value > 0, 'ZPancakeSwap::06:02');
        require(path.length == 2, 'ZPancakeSwap::06:03');
        require(path[0] != address(0) && path[1] != address(0), 'ZPancakeSwap::06:04');
        require(path[0] != to && path[1] != to, 'ZPancakeSwap::06:05');

        return cPSwapRouter.swapETHForExactTokens{ value: msg.value }(amountOut, path, to, deadline); 
    }
}