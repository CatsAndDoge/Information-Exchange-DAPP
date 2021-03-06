pragma solidity ^0.4.24;

contract user {

    struct userStruct {
      string userName;
      address userAddress;
      uint index;
    }

    struct userListStruct {
      address userAddress;
      uint index;
    }

    address[] private userAddresses;              //存储所有地址
    string[] private userNames;                   //存储所有用户名

    mapping (string => userListStruct) userListMap;          //便于用用户名查找地址
    mapping (address => userStruct) userMap;                 //便于用地址查找用户名

    event printUserName(string _name);

    function userNameExist(string _userName) public constant returns (bool) {   //检验用户名是否存在
      if( userNames.length == 0)    return false;
      return (keccak256(userNames[userListMap[_userName].index]) == keccak256(_userName));
    }//string 不能直接用==比较，使用hash函数转换比较较为便捷

    function userAddressExist(address _userAddress)public constant returns (bool) {    //检验地址是否存在
      if(userAddresses.length == 0)    return false;
      return  (userAddresses[userMap[_userAddress].index] == _userAddress);
    }

    function createUser (string _userName)public returns (uint) {   //创建用户返回index
      require(!userAddressExist(msg.sender));
      require(!userNameExist(_userName));

      userAddresses.push(msg.sender);
      userNames.push(_userName);

      userMap[msg.sender] = userStruct({
                                         userName : _userName,
                                         userAddress : msg.sender,
                                         index : userAddresses.length - 1
      });
      userListMap[_userName] = userListStruct({
                                            userAddress : msg.sender,
                                            index : userNames.length - 1
      });

      printUserName(_userName);                                                     //监听事件，返回用户名
      return userAddresses.length - 1;
    }

    function inquireUserA(address _userAddress)public constant returns (string, address, uint) {   //根据地址查找用户信息
      require(userAddressExist(_userAddress));

      return (
        userMap[_userAddress].userName,
        userMap[_userAddress].userAddress,
        userMap[_userAddress].index
     );
    }

    function inquireUserN(string _userName)public constant returns (string, address, uint) {   //根据用户名查找用户信息
      require(userNameExist(_userName));
      address _userAddress = userListMap[_userName].userAddress;

      return (
        userMap[_userAddress].userName,
        userMap[_userAddress].userAddress,
        userMap[_userAddress].index
       );
}

    function changeUserName(string _name)public returns (bool) { //修改用户姓名
      require(userAddressExist(msg.sender));

      string initName = userMap[msg.sender].userName;
      uint initIndex = userMap[msg.sender].index;

      delete userListMap[initName];
      userListMap[_name] = userListStruct({
                                            userAddress : msg.sender,
                                            index : initIndex
      });
      userMap[msg.sender].userName = _name;

      userNames[initIndex] = _name;
      printUserName(_name);
    
      return true;
    }

/*
                   以及修改其余用户信息的函数
*/

    function deleteUser()public returns (bool){ //删除用户信息，删除成功返回true
      delete userListMap[userMap[msg.sender].userName];
      delete userNames[userMap[msg.sender].index];
      delete userAddresses[userMap[msg.sender].index];
      delete userMap[msg.sender];

      return true;
    
    }

}
