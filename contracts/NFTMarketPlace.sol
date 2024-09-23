// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NFTMarketPlace is ERC721URIStorage, Ownable, ReentrancyGuard {
    error AddressZeroDetected();
    error InsufficientFunds();
    error ZeroValueNotAllowed();
    error NotAnNFT();
    error NotNFTOwner();
    error NFTNotForSale();
    error InvalidNFT();
    error NotApproved();

    uint256 public fee;
    uint256 private nftId;
    mapping(uint256 => uint256) public tokenPrices;
    mapping(uint256 => bool) public isForSale;

    event Minted(uint256 indexed nftId, address indexed owner);
    event TransferNFTSuccessful(uint256 nftId, address indexed from, address to);

    constructor(uint256 _fee) ERC721("UDVee NFT", "UNFT") Ownable(msg.sender) {
        fee = _fee;
    }

     function mint(string memory _tokenURI) public onlyOwner {

       uint256 _newItemId = nftId++;

        _safeMint(msg.sender, _newItemId);
        _setTokenURI(_newItemId, _tokenURI);

        emit Minted(_newItemId, msg.sender);
    }

    function transferNFTOwnership(uint _nftId) public payable nonReentrant {
        if(msg.sender == address(0)) {
            revert AddressZeroDetected();
        }

        if(ownerOf(_nftId) == address(0)) {
            revert NotAnNFT();
        }

        if(tokenPrices[_nftId] != msg.value) {
            revert InsufficientFunds();
        }

        if(isForSale[_nftId] == false) {
            revert NFTNotForSale();
        }

        uint256 feeAmount = (msg.value * fee) / 10000;

        uint256 sellerAmount = msg.value - feeAmount;

        tokenPrices[_nftId] = 0;
        isForSale[_nftId] = false;

        payable(ownerOf(_nftId)).transfer(sellerAmount);
        payable(owner()).transfer(feeAmount);

        if (getApproved(_nftId) != msg.sender) {
        revert NotApproved();
        }

        address previousOwner = ownerOf(_nftId);

        safeTransferFrom(ownerOf(_nftId), msg.sender, _nftId);


        emit TransferNFTSuccessful(nftId, previousOwner, msg.sender);

    }
    

    function listNFTForSale(uint256 _nftId, uint256 _price) public {
        if(msg.sender == address(0)) {
            revert AddressZeroDetected();
        }

        if(ownerOf(_nftId) != msg.sender) {
            revert NotNFTOwner();
        }

        if(_price == 0) {
            revert ZeroValueNotAllowed();
        }

        tokenPrices[_nftId] = _price;
        isForSale[_nftId] = true;
    }

    function setPlatformFee(uint256 _newFee) public onlyOwner {
        if(msg.sender == address(0)) {
            revert AddressZeroDetected();
        }

        if(_newFee == 0) {
            revert ZeroValueNotAllowed();
        }

        fee = _newFee;
    }
}