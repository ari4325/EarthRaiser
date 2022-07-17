// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "./EarthNFT.sol";

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract EarthCore {

    struct Project{
        address user;
        string project_name;
        string project_description;
        uint tokenId;
        uint fundsSeeked;
    }

   mapping(address => Project[]) userProjects;
   mapping(address => uint[]) userTokens;

   mapping(uint => Project) tokenToProject;
   mapping(uint => address) tokenToUser;
   mapping(uint => bool) tokenProjectStatus;
   mapping(uint => uint) tokenFundsSeeked;
   mapping(address => uint) totalFundsReceived;

   Project[] projects; 

   address _owner;
   EarthRaiserNFT _tokenContract;
   IERC20 USDC;

   event ProjectCreated(address indexed user, string indexed name, uint indexed tokenID) ; 

   modifier isActiveProject(){_;}

  constructor(address _NFTProject, address tokenAddress) {
      _owner = msg.sender;
      _tokenContract = EarthRaiserNFT(_NFTProject);
      USDC = IERC20(tokenAddress);
  }

  function createProject(string memory projectName, string memory project_desc, string memory uri, uint _fundSeeked) external {
      uint token = _tokenContract.createToken(msg.sender, uri);
      Project memory prj = Project(msg.sender, projectName, project_desc, token, _fundSeeked * (10 ** 18));

      tokenProjectStatus[token] = true;
      tokenToProject[token] = prj;
      tokenToUser[token] = msg.sender;
      tokenFundsSeeked[token] = _fundSeeked;

      userTokens[msg.sender].push(token);
      userProjects[msg.sender].push(prj);

      projects.push(prj);
  }

  function fundProject(uint tokenID) external {
      require(tokenProjectStatus[tokenID], "Inactive token contract");
      Project storage prj = tokenToProject[tokenID];
      uint funds = prj.fundsSeeked;

      require(USDC.allowance(msg.sender, address(this)) >= funds, "User has not approved transfer");
      require(USDC.transferFrom(msg.sender, prj.user, funds), "Fund transfer failed");

      //_tokenContract.transferFrom(prj.user, msg.sender, tokenID);
      totalFundsReceived[prj.user] += prj.fundsSeeked;

      tokenProjectStatus[tokenID] = false;
  }

  function getUserTokens() external view returns(uint[] memory){
      return userTokens[msg.sender];
  }

  function getUserTokens(address _user) external view returns(uint[] memory){
      return userTokens[_user];
  }

  function getUserTokenCount() external view returns(uint){
      return userTokens[msg.sender].length;
  }

  function getUserTokenCount(address _user) external view returns(uint){
      return userTokens[_user].length;
  }

  function getUserFunding(address _user) external view returns(uint) {
      return totalFundsReceived[_user];
  }

  function getProjectData(uint _token) external view returns (Project memory) {
      return tokenToProject[_token];
  }
}