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
        uint tokenId;
        uint fundsSeeked;
    }

   mapping(address => uint) userParticipationType;
   mapping(address => string) userName;
   mapping(address => Project) userActiveProject;
   mapping(address => Project[]) userProjects;

   mapping(uint => Project) tokenToProject;
   mapping(uint => address) tokenToUser;
   mapping(uint => bool) tokenProjectStatus;
   mapping(uint =>  uint) tokenFundsSeeked;

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

  function participate(string memory name, uint _type) external {
      userName[msg.sender] = name;
      userParticipationType[msg.sender] = _type;
  }

  function createProject(string memory projectName, string memory uri, uint _fundSeeked) external {
      uint token = _tokenContract.createToken(msg.sender, uri);
      Project memory prj = Project(msg.sender, projectName, token, _fundSeeked);

      tokenProjectStatus[token] = true;
      tokenToProject[token] = prj;
      tokenToUser[token] = msg.sender;
      tokenFundsSeeked[token] = _fundSeeked;

      userActiveProject[msg.sender] = prj;
      userProjects[msg.sender].push(prj);

      projects.push(prj);
  }

  function fundProject(uint tokenID) external {
      require(tokenProjectStatus[tokenID], "Inactive token contract");
      Project storage prj = tokenToProject[tokenID];
      uint funds = prj.fundsSeeked;

      require(USDC.allowance(msg.sender, prj.user) >= funds, "User has not approved transfer");
      require(USDC.transferFrom(msg.sender, prj.user, funds), "Fund transfer failed");

      _tokenContract.transferFrom(prj.user, msg.sender, tokenID);

      tokenProjectStatus[tokenID] = false;
      delete userActiveProject[msg.sender];
  }

  function getActiveProject() external view returns(Project memory) {
      return userActiveProject[msg.sender];
  }

  
}