pragma solidity >=0.5.0;

import "../tokens/interfaces/IBEP20.sol";

import "./interfaces/IBurgerSwapRouter.sol";
import "../IZethyrSwapMemory.sol";

contract ZethyrBurgerSwap {
    address public owner;
    address public WBNB;
    uint8 public version = 100;
    IBurgerSwapRouter public cBSwapRouter;
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
        address _cBSwapRouterAddr,
        address _cZSwapMemoryAddr
        ) public {
        owner = msg.sender;
        IBurgerSwapRouter _IBurgerSwapRouter = IBurgerSwapRouter(_cBSwapRouterAddr);
        cBSwapRouter = _IBurgerSwapRouter;

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
        amounts = cBSwapRouter.getAmountsOut(amountIn, path);
        /*------------------------- validate -----------------------------------*/
        require(amounts[amounts.length - 1] >= amountOutMin, 'ZBurgerSwap::01:00');
        require(amountIn > 0, 'ZBurgerSwap::01:01');
        require(amountOutMin > 0, 'ZBurgerSwap::01:02');
        require(path.length == 2, 'ZBurgerSwap::01:03');
        require(path[0] != address(0) && path[1] != address(0), 'ZBurgerSwap::01:04');
        require(path[0] != to && path[1] != to, 'ZBurgerSwap::01:05');
        require(IBEP20(path[0]).balanceOf(msg.sender) >= amountIn, 'ZBurgerSwap::01:06');
        /*------------------------- handle -------------------------------------*/
        // get Token
        IBEP20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        
        cBSwapRouter.swapExactTokensForTokens(amountIn, amountOutMin, path, to, now);

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
        amounts = cBSwapRouter.getAmountsOut(msg.value, path);
        /*------------------------- validate -----------------------------------*/
        require(path[0] == WBNB, 'ZBurgerSwap: INVALID_PATH');
        require(amounts[amounts.length - 1] >= amountOutMin, 'ZBurgerSwap::03:00');
        require(amountOutMin > 0, 'ZBurgerSwap::03:01');
        require(msg.value > 0, 'ZBurgerSwap::03:02');
        require(path.length == 2, 'ZBurgerSwap::03:03');
        require(path[0] != address(0) && path[1] != address(0), 'ZBurgerSwap::03:04');
        require(path[0] != to && path[1] != to, 'ZBurgerSwap::03:05');
        /*------------------------- handle -------------------------------------*/
        cBSwapRouter.swapExactETHForTokens.value(msg.value)(amountOutMin, path, to, now);  

        cZSwapMemory.createSwapHistory(msg.sender, to, path[0], path[1], msg.value, amounts[amounts.length - 1]); 
        /*------------------------ emit event ----------------------------------*/
        emit onCreateSwapHistory(msg.sender, to, path[0], path[1], msg.value, amounts[amounts.length - 1]); 
    }
    function swapExactTokensForBNB(uint amountIn, uint amountOutMin, address[] calldata path, address to) 
        external
        returns (uint[] memory amounts)
    {
        /*------------------------- declare ------------------------------------*/
        amounts = cBSwapRouter.getAmountsOut(amountIn, path);
        /*------------------------- validate -----------------------------------*/
        require(path[path.length - 1] == WBNB, 'ZBurgerSwap: INVALID_PATH');
        require(amounts[amounts.length - 1] >= amountOutMin, 'ZBurgerSwap::05:00');
        require(amountOutMin > 0, 'ZBurgerSwap::05:01');
        require(amountIn > 0, 'ZBurgerSwap::05:02');
        require(path.length == 2, 'ZBurgerSwap::05:03');
        require(path[0] != address(0) && path[1] != address(0), 'ZBurgerSwap::05:04');
        require(path[0] != to && path[1] != to, 'ZBurgerSwap::05:05');
        require(IBEP20(path[0]).balanceOf(msg.sender) >= amountIn, 'ZBurgerSwap::05:06');
        /*------------------------- handle -------------------------------------*/
        // get Token        
        IBEP20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        
        cBSwapRouter.swapExactTokensForETH(amountIn, amountOutMin, path, to, now);

        cZSwapMemory.createSwapHistory(msg.sender, to, path[0], path[1], amountIn, amounts[amounts.length - 1]); 
        /*------------------------ emit event ----------------------------------*/
        emit onCreateSwapHistory(msg.sender, to, path[0], path[1], amountIn, amounts[amounts.length - 1]); 
    }
    // ----------------------------------------------------------------------------
    // Load
    // ----------------------------------------------------------------------------
}