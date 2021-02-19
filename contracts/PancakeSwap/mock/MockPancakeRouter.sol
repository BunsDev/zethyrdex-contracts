pragma solidity =0.5.16;

import "../../tokens/interfaces/IBEP20.sol";

contract MockPancakeRouter {
    uint[] public mockAmounts = [5000000, 10000000];
    constructor() public {
        
    }
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external  returns (uint[] memory amounts) {
        IBEP20(path[0]).transferFrom(msg.sender, address(this), amountIn);
    }
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        IBEP20(path[0]).transferFrom(msg.sender, address(this), amountInMax);
    }
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts)
    {
        require(msg.value > 0, 'msg.value > 0');
    }
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts)
    {
        IBEP20(path[0]).transferFrom(msg.sender, address(this), amountInMax);
    }
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) 
        external
        returns (uint[] memory amounts)
    {
        IBEP20(path[0]).transferFrom(msg.sender, address(this), amountIn);
    }
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts)
    {
       require(msg.value > 0, 'msg.value > 0');
    }

    function getAmountsOut(uint amountIn, address[] memory path)
        public
        view
        returns (uint[] memory amounts)
    {
        amounts = mockAmounts;
    }

    function getAmountsIn(uint amountOut, address[] memory path)
        public
        view
        returns (uint[] memory amounts)
    {
        amounts = mockAmounts;
    }
}
