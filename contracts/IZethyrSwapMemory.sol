pragma solidity >=0.5.0;

interface IZethyrSwapMemory {
	function createSwapHistory(address _userAddr, address _receiverAddr, address _from, address _to, uint256 _amountSold, uint256 _amountGet) external; 
}