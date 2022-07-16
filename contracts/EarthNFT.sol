// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract EarthRaiserNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address deployer;
    address contractAddress;

    modifier onlyDeployer {
        require(msg.sender == deployer, "Only deployer can update this function");
        _; 
    }

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        deployer = msg.sender;
    }

    function setCoreAddress(address coreContract) external onlyDeployer{
        contractAddress = coreContract;
    }

    function createToken(address minter, string memory tokenURI) public returns (uint) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
		
        _mint(minter, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}