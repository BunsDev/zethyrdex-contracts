pragma solidity =0.5.16;

import "../../tokens/interfaces/IBEP20.sol";

contract MockBakeryRouter {
    uint[] public mockAmounts = [5100000, 11000000];
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
    function swapExactBNBForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts)
    {
        require(msg.value > 0, 'msg.value > 0');
    }
    function swapExactTokensForBNB(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) 
        external
        returns (uint[] memory amounts)
    {
        IBEP20(path[0]).transferFrom(msg.sender, address(this), amountIn);
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
