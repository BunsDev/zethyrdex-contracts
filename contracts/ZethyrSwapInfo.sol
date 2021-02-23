pragma solidity >=0.5.0;

import "./BakerySwap/interfaces/IBakerySwapRouter.sol";
import "./PancakeSwap/interfaces/IPancakeSwapRouter.sol";
import "./BurgerSwap/interfaces/IBurgerSwapRouter.sol";

contract ZethyrSwapInfo {

    uint8 public version = 101;
    address public owner;
    IBurgerSwapRouter public cBurgerSwapRouter;
    IBakerySwapRouter public cBakerySwapRouter;
    IPancakeSwapRouter public cPancakeSwapRouter;

    mapping(address => mapping(address => bool)) public isIgnoreOfPancake;
    mapping(address => mapping(address => bool)) public isIgnoreOfBakery;
    mapping(address => mapping(address => bool)) public isIgnoreOfBurger;

    modifier onlyOwner()
    {
        require(msg.sender == owner, 'only_owner');
        _;
    }

    constructor(
        address _cPancakeSwapRouterAddr,
        address _cBurgerSwapRouterAddr,
        address _cBakerySwapRouterAddr
        ) public {

            owner = msg.sender;

            IPancakeSwapRouter _IPancakeSwapRouter = IPancakeSwapRouter(_cPancakeSwapRouterAddr);
            cPancakeSwapRouter = _IPancakeSwapRouter;

            IBakerySwapRouter _IBakerySwapRouter = IBakerySwapRouter(_cBakerySwapRouterAddr);
            cBakerySwapRouter = _IBakerySwapRouter;

            IBurgerSwapRouter _IBurgerSwapRouter = IBurgerSwapRouter(_cBurgerSwapRouterAddr);
            cBurgerSwapRouter = _IBurgerSwapRouter;
    }
    /**
    * Action::updateIgnoreOfPancake 
    */
    function updateIgnoreOfPancake(address _tokenA, address _tokenB) public onlyOwner {
        isIgnoreOfPancake[_tokenA][_tokenB] = !isIgnoreOfPancake[_tokenA][_tokenB];
    }
    /**
    * Action::updateIgnoreOfBakery 
    */
    function updateIgnoreOfBakery(address _tokenA, address _tokenB) public onlyOwner {
        isIgnoreOfBakery[_tokenA][_tokenB] = !isIgnoreOfBakery[_tokenA][_tokenB];
    }
     /**
    * Action::updateIgnoreOfBurger 
    */
    function updateIgnoreOfBurger(address _tokenA, address _tokenB) public onlyOwner {
        isIgnoreOfBurger[_tokenA][_tokenB] = !isIgnoreOfBurger[_tokenA][_tokenB];
    }
    function getAmountsIn(uint amountOut, address[] memory path) public view returns(uint[6] memory _data) {
    
        uint[] memory amounts;

        if (isIgnoreOfPancake[path[0]][path[1]] == false) {
            amounts = cPancakeSwapRouter.getAmountsIn(amountOut, path);
            _data[0] = amounts[0];
            _data[1] = amounts[1];
        }
        if (isIgnoreOfBakery[path[0]][path[1]] == false) {
            amounts = cBakerySwapRouter.getAmountsIn(amountOut, path);
            _data[2] = amounts[0];
            _data[3] = amounts[1];   
        }
        if (isIgnoreOfBurger[path[0]][path[1]] == false) {
            amounts = cBurgerSwapRouter.getAmountsIn(amountOut, path);
            _data[4] = amounts[0];
            _data[5] = amounts[1];   
        }
    }

    function getAmountsOut(uint amountIn, address[] memory path) public view returns(uint[6] memory _data) {
    
        uint[] memory amounts;
        if (isIgnoreOfPancake[path[0]][path[1]] == false) {
            amounts = cPancakeSwapRouter.getAmountsOut(amountIn, path);
            _data[0] = amounts[0];
            _data[1] = amounts[1];
        }
        if (isIgnoreOfBakery[path[0]][path[1]] == false) {
            amounts = cBakerySwapRouter.getAmountsOut(amountIn, path);
            _data[2] = amounts[0];
            _data[3] = amounts[1];
        }
        if (isIgnoreOfBurger[path[0]][path[1]] == false) {
            amounts = cBurgerSwapRouter.getAmountsOut(amountIn, path);
            _data[4] = amounts[0];
            _data[5] = amounts[1];   
        }
    }
}