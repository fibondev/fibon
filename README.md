##Contract List

#FibonToken -> Main Contract: Includes whole operations for transfers and ico processes.

#FibonAdmin -> Admin Contract: Includes administration methods.

#FibonProxy -> Proxy Contract: Includes ERC20 methods to redirect main contract.

#IERC20 -> ERC20 Interface: Includes ERC20 abstract methods to use in FibonProxy and FibonToken. (from openzeppelin)

#IERC20Admin -> ERC20 ICO Interface: Includes ICO abstract methods to use in FibonAdmin and FibonToken.

#IcoUtil -> ICO library: Includes ICO util methods and structures. 

#Address -> Address library: Includes address structure util methods. (from openzeppelin)

#Context -> Context library: Includes message context util methods. (from openzeppelin)

#SafeMath -> Math library: Includes math operations util methods. (from openzeppelin)


##Explanations


#FibonProxy: Customers will use FibonProxy contract that will be certain contract and will not change in the future. Even if main contract will change, proxy contract will be the same so customers doesnt need to change anything to reach their assets. FibonProxy is used for only redirection to FibonToken contract.

#FibonAdmin: This contract will be used for administration and ico processes. It has the similar sturcture with FibonProxy that is used for only redirecction to FibonToken contract. It contains ICO transfer operations.

#FibonToken: It is the main contract that operates whole processes and stores whole data. Its methods cannot be reachable directly so it can be called from FibonProxy and FibonAdmin only. All ICO distributions defined in constructor. During ICO, noone can transfer assets except earlybackers. Some ICO distributions are frozen funds and they are stored and controlled in frozenAddressList property. It has two inherit classes such as IERC20 and IERC20Admin to supply equality with FibonProxy and FibonAdmin contracts.

