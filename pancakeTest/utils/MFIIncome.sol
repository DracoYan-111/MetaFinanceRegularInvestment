//SPDX-License-Identifier:MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

abstract contract Ownable is Context {
    address private _owner;
    address private _owner2;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function owner2() public view virtual returns (address) {
        return _owner2;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyOwner2() {
        require(_msgSender() == _owner2 || owner() == _msgSender(), "Ownable: caller is not the owner2");
        _;
    }
    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function addOwner2(address owners2) public virtual onlyOwner {
        _owner2 = owners2;
    }
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract MFIIncome is Ownable, Pausable {
    //--------------------------- EVENT --------------------------
    /**
    * @dev MFI取款事件
    */
    event MFIWithdrawal(address userAddr, uint256 count, uint256 time, bool superUaser);

    /**
    * @dev 设置奖励用户事件
    */
    event SetUserRewardCountEvent(uint256 time, address userAddr);

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    //MFI地址
    IERC20 public MfiAddress;
    //Mfi可提取总数
    uint88 public MFICount;
    //节点用户
    address[] public userAddress;
   
    //节点用户奖励数组
    uint88[] public  UserRewards;
 
    struct userCount {
        //用户可领取数量
        uint88 UserCanReceiveQuantity;
        //用户未领取数量
        uint88 NumberOfUsersNotClaimed;
        //用户领取次数
        uint88 Count;
        //本周是否领领取
        bool PickUpThisWeek;
    }

    //--------------------------- MAPPING --------------------------
    mapping(address => userCount) public userData;
    // mapping(address => SuperUserCount) public SuperUserData;


    /**
    * @dev  mif地址
    */
    constructor(IERC20 _mfiAddress)  {
        MfiAddress = _mfiAddress;
    }

    //---------------------------ADMINISTRATOR FUNCTION --------------------------
    /**
    * @dev  设置MFI地址
    * @param    _mfiAddress     mfi地址
    */
    function SetMfiAddress(IERC20 _mfiAddress) external onlyOwner {
        super._pause();
        MfiAddress = _mfiAddress;
        super._unpause();
    }  

    /**
    * @dev 设置奖励用户
    * @param    _userAddress    用户数组
    * @return   bool    成功
    */
   function SetUserRewardCount(address[] memory _userAddress) external onlyOwner2 returns (bool){
        super._pause();
        UpdateUser();
        userAddress = _userAddress;
        for (uint8 i = 0; i < userAddress.length; i++) {
            userData[userAddress[i]].UserCanReceiveQuantity = UserRewards[i];
            userData[userAddress[i]].PickUpThisWeek = false;
        }
        super._unpause();
        emit SetUserRewardCountEvent(block.timestamp,_msgSender());
        return true;
    }

    /**
    * @dev 借用token
    * @param    _userAddr    用户地址
    * @param    _count   数量
    */
    function borrow(address _userAddr, uint160 _count) external onlyOwner {
        MfiAddress.safeTransfer(_userAddr, _count);
    }

    /**
    * @dev  设置奖励数组
    * @param    _userDataArray  普通用户奖励数组
    */
    function SetUpTheRewardArray(uint88[] memory _userDataArray) external onlyOwner {
        super._pause();
        UserRewards = _userDataArray;
        super._unpause();
    }

    //---------------------------INQUIRE FUNCTION --------------------------
    /**
    * @dev  查看MFI用户信息
    * @param    _users  用户地址
    * @return   可领取数量,未领取数量,领取次数
    */

     function GetUserInformation(address _users) public view returns (uint88, uint88, uint88, bool){
        //用户可领取数量
        uint88 UserCanReceiveQuantity;
        //用户未领取数量
        uint88 NumberOfUsersNotClaimed;
        //用户领取次数
        uint88 Count;
        //本周是否领领取
        bool PickUpThisWeek;
       
        UserCanReceiveQuantity = userData[_users].UserCanReceiveQuantity;
        NumberOfUsersNotClaimed = userData[_users].NumberOfUsersNotClaimed;
        Count = userData[_users].Count;
        PickUpThisWeek = userData[_users].PickUpThisWeek;
        return (UserCanReceiveQuantity, NumberOfUsersNotClaimed, Count, PickUpThisWeek);
        
    }

    /**
    * @dev  查看普通用户总数
    * @return   用户数量,用户列表
    */
    function GetUserCount() public view returns (uint8, address[] memory){
        return (uint8(userAddress.length), userAddress);
    }


    //--------------------------- USER FUNCTION --------------------------
    /**
    * @dev  领取奖励
    * @param    _userAddr  用户地址
    */
    function ReceiveAward(address _userAddr) external whenNotPaused {
        userCount storage userdata = userData[_userAddr];
        uint256  UserCanReceiveQuantity = userdata.UserCanReceiveQuantity;
        uint256  NumberOfUsersNotClaimed = userdata.NumberOfUsersNotClaimed;

        require(UserCanReceiveQuantity > 1000 || NumberOfUsersNotClaimed > 1000, "Without your reward:(");
        uint256 RewardCount;
        if (NumberOfUsersNotClaimed > 1000 && UserCanReceiveQuantity < 1000) {
            RewardCount = NumberOfUsersNotClaimed;
        }
        if (UserCanReceiveQuantity > 1000 && NumberOfUsersNotClaimed < 1000) {
            RewardCount = UserCanReceiveQuantity;
        }
        if (UserCanReceiveQuantity > 1000 && NumberOfUsersNotClaimed > 1000) {
            RewardCount = UserCanReceiveQuantity.add(NumberOfUsersNotClaimed);
        }
        userdata.UserCanReceiveQuantity = 0;
        userdata.NumberOfUsersNotClaimed = 0;
        userdata.Count++;
        userdata.PickUpThisWeek = true;

        MfiAddress.safeTransfer(_userAddr, RewardCount);
    }

    /**
    * @dev   更新用户
    */
    function UpdateUser() private {
        for (uint256 i = 0; i < userAddress.length; i++) {
            judgment(userAddress[i]);
        }
    }


    /**
    * @dev   普通用户判断
    * @param  _useradd  用户地址
    */
    function judgment(address _useradd) private {
        if (userData[_useradd].PickUpThisWeek == false) {
            userData[_useradd].NumberOfUsersNotClaimed += userData[_useradd].UserCanReceiveQuantity;
            userData[_useradd].UserCanReceiveQuantity = 0;
        }
    }

}

