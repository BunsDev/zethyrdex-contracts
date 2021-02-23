pragma solidity >=0.5.0;

contract ZethyrSwapMemory {
	
	uint8 public version = 100;
	address public owner;

	mapping(address => bool) public contractList;

	uint256 public totalSwap;

	mapping(uint256 => SwapHistory) public swapHistoryList;
	mapping(address => uint256[]) public swapHistoryListOf;

	struct SwapHistory {
    	address zSwapAddr;
    	address userAddr;
    	address receiverAddr;
    	address from;
    	address to;
        uint256 amountSold; 
        uint256 amountGet; 
    }

    modifier onlyOwner()
    {
        require(msg.sender == owner, 'only_owner');
        _;
    }
    modifier onlyContractAllowed()
	{
	    require(contractList[msg.sender] == true, 'only_contract_allowed');
	    _;
	}
	/*--------------------------- declare event ---------------------------------*/
	event onActivateContract(address contractAddr);
	event onDeactivateContract(address contractAddr);
    // ----------------------------------------------------------------------------
    // CONSTRUCTOR
    // ----------------------------------------------------------------------------
    constructor() public {
        owner = msg.sender;
    }
    // ----------------------------------------------------------------------------
    // ACTION
    // ----------------------------------------------------------------------------

    /*--------------------------------OWNER ACTION-------------------------------*/
    /**
	* Action::activateContract
	* @notice Add a contract to the list of allowed contracts
	* @param _addr contract address to activate.
	*/
	function activateContract(address _addr) public onlyOwner {
	    /*------------------------- declare ------------------------------------*/
	    /*------------------------- validate -----------------------------------*/
	    require(contractList[_addr] == false);
	    /*------------------------- handle -------------------------------------*/
	    contractList[_addr] = true;
	    /*------------------------ emit event ----------------------------------*/
	    emit onActivateContract(_addr);
	}
	/**
	* Action::deactivateContract
	* @notice remove a contract to the list of allowed contracts
	* @param _addr contract address to deactivate.
	*/
	function deactivateContract(address _addr) public onlyOwner {
	    /*------------------------- declare ------------------------------------*/
	    /*------------------------- validate -----------------------------------*/
	    require(contractList[_addr] == true);
	    /*------------------------- handle -------------------------------------*/
	    contractList[_addr] = false;
	    /*------------------------ emit event ----------------------------------*/
	    emit onDeactivateContract(_addr);
	}
	/*--------------------------------CONTRACT ACTION-------------------------------*/
	/**
	* Action::createSwapHistory
	*/
	function createSwapHistory(address _userAddr, address _receiverAddr, address _from, address _to, uint256 _amountSold, uint256 _amountGet) public onlyContractAllowed {
		/*------------------------- declare ------------------------------------*/
		uint256 historyIdx = totalSwap;
		SwapHistory storage sHistory = swapHistoryList[historyIdx];
		/*------------------------- handle -------------------------------------*/
		// update swap history
		sHistory.zSwapAddr = msg.sender;
		sHistory.userAddr  = _userAddr;
		sHistory.receiverAddr = _receiverAddr;
		sHistory.from = _from;
		sHistory.to = _to;
		sHistory.amountSold = _amountSold;
		sHistory.amountGet = _amountGet;
		// update user's history
		swapHistoryListOf[_userAddr].push(historyIdx);
		// update total swap
		totalSwap += 1;
	}
	// ----------------------------------------------------------------------------
    // Load
    // ----------------------------------------------------------------------------
    function getUserHistoryList(address _userAddr) public view returns(uint256[] memory) {
    	return swapHistoryListOf[_userAddr];
    }
}