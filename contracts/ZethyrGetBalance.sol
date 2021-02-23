pragma solidity >=0.5.0;

import "./tokens/interfaces/IBEP20.sol";

contract ZethyrGetBalance  {
 

  function getBEP20Balance(address _tokenAddr, address _addrGetBalance) public view returns(uint256) {
    IBEP20 interfaceToken = IBEP20(_tokenAddr);
    return interfaceToken.balanceOf(_addrGetBalance);
  }
  function getBNBBalance(address _addrGetBalance) public view returns(uint256) {
    return address(_addrGetBalance).balance; 
  }
}