// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketPlace is ERC721URIStorage, Ownable {

    uint256 public fee;
    uint256 private nftId;
    mapping(uint256 => address) private owners;
    mapping(uint256 => uint256) public tokenPrices;
    mapping(uint256 => bool) public isForSale;

    event Minted(uint256 nftId);
    event TransferNFTSuccessful(uint256 nftId);

    constructor(uint256 _fee) ERC721("UDVee NFT", "UNFT") Ownable(msg.sender) {
        fee = _fee;
    }

     function mint(string memory _tokenURI) public onlyOwner {

       uint256 _newItemId = _nftId++;

        _safeMint(msg.sender, _newItemId);
        _setTokenURI(_newItemId, _tokenURI);

        owners[_newItemId] = msg.sender;

        emit Minted(_newItemId);
    }
};