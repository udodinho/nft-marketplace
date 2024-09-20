// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketPlace is ERC721URIStorage, Ownable {
    error AddressZeroDetected();
    error InsufficientFunds();
    error ZeroValueNotAllowed();
    error NotAnNFT();
    error NotNFTOwner();


    address public owner;
    uint256 public fee;
    uint256 private nftId;
    mapping(uint256 => address) private owners;
    mapping(uint256 => uint256) public tokenPrices;
    mapping(uint256 => bool) public isForSale;

    event Minted(uint256 nftId);
    event TransferNFTSuccessful(uint256 nftId);

    constructor(uint256 _fee) ERC721("UDVee NFT", "UNFT") Ownable(msg.sender) {
        fee = _fee;
        owner = msg.sender;
    }

     function mint(string memory _tokenURI) public onlyOwner {

       uint256 _newItemId = _nftId++;

        _safeMint(msg.sender, _newItemId);
        _setTokenURI(_newItemId, _tokenURI);

        owners[_newItemId] = msg.sender;

        emit Minted(_newItemId);
    }

    unction transferNFTOwnership(uint _nftId) public payable {
        if(msg.sender == address(0)) {
            revert AddressZeroDetected();
        }

        if(ownerOf(_nftId) == address(0)) {
            revert NotAnNFT();
        }

        if(tokenPrices[_nftId] != msg.value) {
            revert InsufficientFunds();
        }

        uint256 feeAmount = (msg.value * fee) / 10000;

        uint256 sellerAmount = msg.value - feeAmount;
        ownerOf(_nftId).transfer(owners, sellerAmount);

        payable(owner()).transfer(feeAmount);

        tokenPrices[_nftId] = 0;
        safeTransferFrom(ownerOf(_nftId), msg.sender, _nftId);
    }

    function listNFTForSale(uint256 _nftId, uint256 _price) public {
        if(msg.sender == address(0)) {
            revert AddressZeroDetected();
        }

        if(ownerOf(_nftId) != msg.sender) {
            revert NotNFTOwner();
        }

        if(price == 0) {
            revert ZeroValueNotAllowed();
        }

        tokenPrices[_nftId] = price;
        isForSale[_nftId] = true;
    }
};