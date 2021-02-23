pragma solidity >=0.5.0;

import "../tokens/interfaces/IBEP20.sol";

import "./interfaces/IPancakeSwapRouter.sol";
import "../IZethyrSwapMemory.sol";

contract ZethyrPancakeSwap {
    address public owner;
    address public WBNB;
    uint8 public version = 100;
    IPancakeSwapRouter public cPSwapRouter;
    IZethyrSwapMemory public cZSwapMemory;
    modifier onlyOwner()
    {
        require(msg.sender == owner, 'only_owner');
        _;
    }

    event onCreateSwapHistory(address _userAddr, address _receiverAddr, address _from, address _to, uint256 _amountSold, uint256 _amountGet);
    // ----------------------------------------------------------------------------
    // CONSTRUCTOR
    // ----------------------------------------------------------------------------
    constructor(
        address _WBNB,
        address _cPSwapRouterAddr,
        address _cZSwapMemoryAddr
        ) public {
        owner = msg.sender;
        IPancakeSwapRouter _IPancakeSwapRouter = IPancakeSwapRouter(_cPSwapRouterAddr);
        cPSwapRouter = _IPancakeSwapRouter;

        IZethyrSwapMemory _IZethyrSwapMemory = IZethyrSwapMemory(_cZSwapMemoryAddr);
        cZSwapMemory = _IZethyrSwapMemory;

        WBNB = _WBNB;
    }

      /**
    * Action::manualApproveTransfer
    */
    function manualApproveTransfer(address _tokenAddr, address _spender) public onlyOwner returns(bool) {
        return IBEP20(_tokenAddr).approve(_spender, uint(-1));
    }

    function setContractZethyrSwapMemory(address _addr) public onlyOwner {
        IZethyrSwapMemory _IZethyrSwapMemory = IZethyrSwapMemory(_addr);
        cZSwapMemory = _IZethyrSwapMemory;
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to
    ) external returns (uint[] memory amounts) {
        /*------------------------- declare ------------------------------------*/
        amounts = cPSwapRouter.getAmountsOut(amountIn, path);
        /*------------------------- validate -----------------------------------*/
        require(amounts[amounts.length - 1] >= amountOutMin, 'ZPancakeSwap::01:00');
        require(amountIn > 0, 'ZPancakeSwap::01:01');
        require(amountOutMin > 0, 'ZPancakeSwap::01:02');
        require(path.length == 2, 'ZPancakeSwap::01:03');
        require(path[0] != address(0) && path[1] != address(0), 'ZPancakeSwap::01:04');
        require(path[0] != to && path[1] != to, 'ZPancakeSwap::01:05');
        require(IBEP20(path[0]).balanceOf(msg.sender) >= amountIn, 'ZPancakeSwap::01:06');
        /*------------------------- handle -------------------------------------*/
        // get Token
        IBEP20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        
        cPSwapRouter.swapExactTokensForTokens(amountIn, amountOutMin, path, to, now);

        cZSwapMemory.createSwapHistory(msg.sender, to, path[0], path[1], amountIn, amounts[amounts.length - 1]); 
        /*------------------------ emit event ----------------------------------*/
        emit onCreateSwapHistory(msg.sender, to, path[0], path[1], amountIn, amounts[amounts.length - 1]);
    }
    function swapExactBNBForTokens(uint amountOutMin, address[] calldata path, address to)
        external
        payable
        returns (uint[] memory amounts)
    {
        /*------------------------- declare ------------------------------------*/
        amounts = cPSwapRouter.getAmountsOut(msg.value, path);
        /*------------------------- validate -----------------------------------*/
        require(path[0] == WBNB, 'ZPancakeSwap: INVALID_PATH');
        require(amounts[amounts.length - 1] >= amountOutMin, 'ZPancakeSwap::03:00');
        require(amountOutMin > 0, 'ZPancakeSwap::03:01');
        require(msg.value > 0, 'ZPancakeSwap::03:02');
        require(path.length == 2, 'ZPancakeSwap::03:03');
        require(path[0] != address(0) && path[1] != address(0), 'ZPancakeSwap::03:04');
        require(path[0] != to && path[1] != to, 'ZPancakeSwap::03:05');
        /*------------------------- handle -------------------------------------*/
        cPSwapRouter.swapExactETHForTokens.value(msg.value)(amountOutMin, path, to, now);  

        cZSwapMemory.createSwapHistory(msg.sender, to, path[0], path[1], msg.value, amounts[amounts.length - 1]); 
        /*------------------------ emit event ----------------------------------*/
        emit onCreateSwapHistory(msg.sender, to, path[0], path[1], msg.value, amounts[amounts.length - 1]); 
    }
    function swapExactTokensForBNB(uint amountIn, uint amountOutMin, address[] calldata path, address to) 
        external
        returns (uint[] memory amounts)
    {
        /*------------------------- declare ------------------------------------*/
        amounts = cPSwapRouter.getAmountsOut(amountIn, path);
        /*------------------------- validate -----------------------------------*/
        require(path[path.length - 1] == WBNB, 'ZPancakeSwap: INVALID_PATH');
        require(amounts[amounts.length - 1] >= amountOutMin, 'ZPancakeSwap::05:00');
        require(amountOutMin > 0, 'ZPancakeSwap::05:01');
        require(amountIn > 0, 'ZPancakeSwap::05:02');
        require(path.length == 2, 'ZPancakeSwap::05:03');
        require(path[0] != address(0) && path[1] != address(0), 'ZPancakeSwap::05:04');
        require(path[0] != to && path[1] != to, 'ZPancakeSwap::05:05');
        require(IBEP20(path[0]).balanceOf(msg.sender) >= amountIn, 'ZPancakeSwap::05:06');
        /*------------------------- handle -------------------------------------*/
        // get Token        
        IBEP20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        
        cPSwapRouter.swapExactTokensForETH(amountIn, amountOutMin, path, to, now);

        cZSwapMemory.createSwapHistory(msg.sender, to, path[0], path[1], amountIn, amounts[amounts.length - 1]); 
        /*------------------------ emit event ----------------------------------*/
        emit onCreateSwapHistory(msg.sender, to, path[0], path[1], amountIn, amounts[amounts.length - 1]); 
    }
    // ----------------------------------------------------------------------------
    // Load
    // ----------------------------------------------------------------------------
}