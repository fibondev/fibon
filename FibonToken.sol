pragma solidity ^0.8.0;

import "./Context.sol";
import "./IERC20.sol";
import "./IERC20Admin.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./IcoUtil.sol";


    
    


contract FibonToken is Context, IERC20, IERC20Admin {
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
    address private owner;
    address private proxyAddress;
    address private adminAddress;
    
    //utils
    
    uint256 private oneYearParam = 31536000; //1 year
    uint256 private sixMonthsParam = 15552000;  //180 days
    uint256 private threeMonthsParam = 7776000; //90 days
    
    
    uint256 private icoPart1Deadline;
    uint256 private icoPart2Deadline;
    uint256 private icoPart3Deadline;
    
    
    
    //management addresses;
    address private icoPart1HolderAddress;
    address private icoPart2HolderAddress;
    address private icoPart3HolderAddress;
    address private earlyBackerHolderAddress;
    
    //distributon addresses
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
    constructor (address adminContract) {
            
        address icoPart1Address; 
        address icoPart2Address;
        address icoPart3Address; 
        address shareHolderAddress1; 
        address shareHolderAddress2;
        address shareHolderAddress3;
        address earlyBackerAddress;
        address webSiteTradeAddress;
        address dexAddress;
        address marketingAddress;
        address partnerAddress;
        address researchAddress;
        address frozenFundAddress;
            
            
            
        owner = _msgSender();
        adminAddress = adminContract;
        proxyAddress = address(0);
        
        
        //ico deadlines
        
        icoPart1Deadline = getTime() + oneYearParam;
        icoPart2Deadline = getTime() + sixMonthsParam;
        icoPart3Deadline = getTime() + threeMonthsParam;
        
        
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
        
        frozenAddressList[shareHolderAddress1] = getTime() + oneYearParam;
        frozenAddressList[shareHolderAddress2] = getTime() + oneYearParam;
        frozenAddressList[shareHolderAddress3] = getTime() + oneYearParam;
        
        
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
        
        //frozen fund distribution
        
        _balances[frozenFundAddress] = 3255308500;
        frozenAddressList[frozenFundAddress] = getTime() + (2*oneYearParam);

        
        
        currentStage = IcoStages.icoPart1;
        
    }
    
    //IERC20 methods

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
    
    function frozenUntil(address account) public view override returns (uint256) {
        return frozenAddressList[account];
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
        
       
        if(frozenAddressList[sender] > 0){
            require(isTimeUp(frozenAddressList[sender]), "ERC20: sender account locked yet");
            delete frozenAddressList[sender];
        }

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    
    
    //IERC20Admin methods
    
    function icoTransfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(_msgSender() == adminAddress, "ERC20: Unauthorized access");
        _icoTransfer(recipient, amount);
        return true;
    }
    
   
    function _icoTransfer(address recipient, uint256 amount) internal virtual {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(!currentStage.isFinished(), "ERC20: ico has been finished");
        require(amount > 0, "ERC20: transfer zero amount");
        
        address sender = address(0);
        if(currentStage == IcoStages.icoPart1) 
            sender = icoPart1HolderAddress;
        if(currentStage == IcoStages.icoPart2) {
            sender = icoPart2HolderAddress;
            require(icoPart1Addresses[recipient] == 0,"ERC20: ico1 already used");
        }
        if(currentStage == IcoStages.icoPart3) {
            sender = icoPart3HolderAddress;
            require(icoPart1Addresses[recipient] == 0,"ERC20: ico1 already used");
            require(icoPart2Addresses[recipient] == 0,"ERC20: ico2 already used");
        }
        
         require(sender != address(0), "ERC20: ico holder cannot be found");
        //_beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: ico transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        if(currentStage == IcoStages.icoPart1) {
            icoPart1Addresses[recipient] = icoPart1Deadline;
            frozenAddressList[recipient] = icoPart1Deadline;
        }
            
        if(currentStage == IcoStages.icoPart2) {
            icoPart2Addresses[recipient] = icoPart2Deadline;
            frozenAddressList[recipient] = icoPart2Deadline;
        }
            
        if(currentStage == IcoStages.icoPart3) {
            icoPart3Addresses[recipient] = icoPart3Deadline;
            frozenAddressList[recipient] = icoPart3Deadline;
        }
            
        
        emit Transfer(sender, recipient, amount);
    }
    
   
    function earlyBackerTransfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(_msgSender() == adminAddress, "ERC20: Unauthorized access");
        _earlyBackerTransfer(recipient, amount);
        return true;
    }
    
   
    function _earlyBackerTransfer(address recipient, uint256 amount) internal virtual {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: transfer zero amount");
        
        address sender = earlyBackerHolderAddress;
         require(sender != address(0), "ERC20: early backer holder cannot be found");
        

        _balances[sender] = _balances[sender].sub(amount, "ERC20: early backer transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        
        earlyBackerAddresses[recipient] = getTime()+sixMonthsParam; 
        frozenAddressList[recipient] = getTime()+sixMonthsParam; 
        
        emit Transfer(sender, recipient, amount);
    }
  

    function burn(address account, uint256 amount) public virtual override returns (bool) {
        require(_msgSender() == adminAddress, "ERC20: Unauthorized access");
        _burn(account, amount);
        return true;
    }

    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        require(amount > 0, "ERC20: transfer zero amount");

        //_beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    
    
    function setProxyContract(address proxyContract) public virtual override returns (bool) {
        require(proxyContract != address(0), "ERC20: proxy contract zero address");
        require(_msgSender() == adminAddress, "ERC20: Unauthorized access");
        
        proxyAddress = proxyContract;
        return true;
    }
    
      
    function upgradeIcoStage() public virtual override returns (bool) {
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
    
    
    function getTime() internal view returns (uint256){
        return block.timestamp;
    }
    
    function isTimeUp(uint256 time) internal view returns (bool){
        return block.timestamp > time;
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}