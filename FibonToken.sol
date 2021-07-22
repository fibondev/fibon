pragma solidity ^0.6.0;

import "./Context.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./IcoUtil.sol";


    
    


contract FibonToken is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;
    using IcoUtil for IcoStages;
    
    //contract params
    uint256 private _totalSupply = 5000000000;

    string private _name = "FIBON";
    string private _symbol = "FIBON";
    uint8 private _decimals = 0;

    mapping (address => uint256) private _balances;
    
    
    
    //other contracts
    address payable owner;
    address proxyAddress;
    address adminAddress;
    
    //utils
    
    uint256 private oneYearParam = 31536000; //1 year
    uint256 private sixMonthsParam = 15552000;  //180 days
    uint256 private threeMonthsParam = 7776000; //90 days
    
    
    
    //management addresses;
    address payable private icoPart1HolderAddress;
    address payable private icoPart2HolderAddress;
    address payable private icoPart3HolderAddress;
    address payable private earlyBackerHolderAddress;
    
    //distributon addresses
    //todo put dates
    mapping (address => uint256) private shareholderAddresses;
    mapping (address => uint256) private earlyBackerAddresses;
    mapping (address => uint256) private icoPart1Addresses;
    mapping (address => uint256) private icoPart2Addresses;
    mapping (address => uint256) private icoPart3Addresses;
    
    mapping (address => uint256) private frozenAddressList;
    
    IcoStages private currentStage;

    
    
    
    

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (
        address payable icoPart1Address, 
        address payable icoPart2Address,
        address payable icoPart3Address, 
        address payable shareHolderAddress1, 
        address payable shareHolderAddress2,
        address payable shareHolderAddress3,
        address payable shareHolderAddress4,
        address payable earlyBackerAddress,
        address payable webSiteTradeAddress,
        address payable dexAddress,
        address payable marketingAddress,
        address payable partnerAddress,
        address payable researchAddress,
        address payable frozenFundAddress
        
        ) public {
        owner = _msgSender();
        
        
        //icoholderdistribution
        
        icoPart1HolderAddress = icoPart1Address;
        icoPart2HolderAddress = icoPart2Address;
        icoPart3HolderAddress = icoPart3Address;
        _balances[icoPart1HolderAddress] = 147681640;
        _balances[icoPart2HolderAddress] = 117681270;
        _balances[icoPart3HolderAddress] = 97317570;
        
        
        
        
        
        //shareHolderDistribution
        
        shareholderAddresses[shareHolderAddress1] = getTime() + oneYearParam;
        shareholderAddresses[shareHolderAddress2] = getTime() + oneYearParam;
        shareholderAddresses[shareHolderAddress3] = getTime() + oneYearParam;
        
        _balances[shareHolderAddress1] = 215888000;
        _balances[shareHolderAddress2] = 95990000;
        _balances[shareHolderAddress3] = 17010000;
        
        
        //earlyBacker distribution
        
        earlyBackerHolderAddress = earlyBackerAddress;
        _balances[earlyBackerAddress] = 28844830;
        
        //other distribution
        
        _balances[webSiteTradeAddress] = 288883000;
        _balances[dexAddress] = 605858050;
        _balances[marketingAddress] = 59155270;
        _balances[partnerAddress] = 39697300;
        _balances[researchAddress] = 30684570;
        
        _balances[frozenFundAddress] = 3255308500;

        
        
        currentStage = IcoStages.icoPart1;
        
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

   

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

  
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    
    
    function upgradeIcoStage() public virtual returns (bool) {
        require(_msgSender() == adminAddress, "ERC20: Unauthorized access");
        require(!currentStage.isFinished(), "ERC20: ICO already finished");
        if(currentStage == IcoStages.icoPart1) 
            currentStage = IcoStages.icoPart2;
        else if(currentStage == IcoStages.icoPart2) 
            currentStage = IcoStages.icoPart3;
        else if(currentStage == IcoStages.icoPart3) 
            currentStage = IcoStages.icoEnd;
        return true;
    }
    
    
    
    
    

 
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(false,"ERC20: not supported");
        return false;
    }

    
    

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        require(_msgSender() == proxyAddress, "ERC20: Unauthorized access");
        _transfer(sender, recipient, amount);
        return true;
    }
    
      

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(currentStage.isFinished(), "ERC20: ico has not been finished");
        require(amount > 0, "ERC20: transfer zero amount");
        
       
        
        //todo check ico  early bracket address

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    
    
    function icoTransfer(address recipient, uint256 amount) public virtual returns (bool) {
        require(_msgSender() == adminAddress, "ERC20: Unauthorized access");
        _icoTransfer(recipient, amount);
        return true;
    }
    
   
    function _icoTransfer(address recipient, uint256 amount) internal virtual {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!currentStage.isFinished(), "ERC20: ico has been finished");
        address sender = address(0);
        if(currentStage == IcoStages.icoPart1) 
            sender = icoPart1HolderAddress;
        if(currentStage == IcoStages.icoPart2) 
            sender = icoPart2HolderAddress;
        if(currentStage == IcoStages.icoPart3) 
            sender = icoPart3HolderAddress;
        
         require(sender != address(0), "ERC20: ico holder cannot be found");
        //_beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: ico transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        if(currentStage == IcoStages.icoPart1) 
            icoPart1Addresses[recipient] = getTime()+oneYearParam;
        if(currentStage == IcoStages.icoPart2) 
            icoPart2Addresses[recipient] = getTime()+sixMonthsParam;
        if(currentStage == IcoStages.icoPart3) 
            icoPart3Addresses[recipient] = getTime()+threeMonthsParam;
        
        emit Transfer(sender, recipient, amount);
    }
    
   
    function earlyBackerTransfer(address recipient, uint256 amount) public virtual returns (bool) {
        require(_msgSender() == adminAddress, "ERC20: Unauthorized access");
        _earlyBackerTransfer(recipient, amount);
        return true;
    }
    
   
    function _earlyBackerTransfer(address recipient, uint256 amount) internal virtual {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        address sender = earlyBackerHolderAddress;
         require(sender != address(0), "ERC20: early backer holder cannot be found");
        //_beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: early backer transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        earlyBackerAddresses[recipient] = getTime()+oneYearParam; 
        emit Transfer(sender, recipient, amount);
    }
    

  

    function burn(address account, uint256 amount) public virtual returns (bool) {
        require(_msgSender() == adminAddress, "ERC20: Unauthorized access");
        _burn(account, amount);
        return true;
    }

    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        //_beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    
    function getTime() internal view returns (uint256){
        return block.timestamp;
    }
    
    function isTimeUp(uint256 time) internal view returns (bool){
        return block.timestamp < time;
    }
    
    
    


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}