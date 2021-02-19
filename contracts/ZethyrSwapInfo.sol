pragma solidity >=0.5.0;

import "./BakerySwap/interfaces/IBakerySwapRouter.sol";
import "./PancakeSwap/interfaces/IPancakeSwapRouter.sol";

contract ZethyrSwapInfo {

    IBakerySwapRouter public cBSwapRouter;
    IPancakeSwapRouter public cPSwapRouter;

    constructor(
        address _cPancakeSwapRouterAddr,
        address _cBakerySwapRouterAddr
        ) public {
            IPancakeSwapRouter _IPancakeSwapRouter = IPancakeSwapRouter(_cPancakeSwapRouterAddr);
            cPSwapRouter = _IPancakeSwapRouter;

            IBakerySwapRouter _IBakerySwapRouter = IBakerySwapRouter(_cBakerySwapRouterAddr);
            cBSwapRouter = _IBakerySwapRouter;
    }

    function getAmountsIn(uint amountOut, address[] memory path) public view returns(uint[4] memory _data) {
    
        uint[] memory amounts;

        amounts = cPSwapRouter.getAmountsIn(amountOut, path);
        _data[0] = amounts[0];
        _data[1] = amounts[1];
        amounts = cBSwapRouter.getAmountsIn(amountOut, path);
        _data[2] = amounts[0];
        _data[3] = amounts[1];
    }

     function getAmountsOut(uint amountIn, address[] memory path) public view returns(uint[4] memory _data) {
    
        uint[] memory amounts;

        amounts = cPSwapRouter.getAmountsOut(amountIn, path);
        _data[0] = amounts[0];
        _data[1] = amounts[1];
        amounts = cBSwapRouter.getAmountsOut(amountIn, path);
        _data[2] = amounts[0];
        _data[3] = amounts[1];
    }
}