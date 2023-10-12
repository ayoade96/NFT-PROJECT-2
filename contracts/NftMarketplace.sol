// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTFractionalize {
    address public owner;
    uint256 public feePercentage; // 0.1% fee
    IERC20 public paymentToken; // ERC20 token for payment

    struct NFT {
        address owner;
        uint256 tokenId;
        uint256 totalSupply;
    }
     mapping(address => NFT) balances;

    NFT[] public nfts;

    event NFTListed(uint256 indexed nftId, address owner, uint256 tokenId, uint256 totalSupply);
    event FractionPurchased(uint256 indexed nftId, address buyer, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(address _paymentToken) {
        owner = msg.sender;
        feePercentage = 10; // 0.1%
        paymentToken = IERC20(_paymentToken); 
    }

    function listNFT(address nftContract, uint256 tokenId, uint256 totalSupply) external {
        require(totalSupply > 0, "Total supply must be greater than 0");
        IERC721 nft = IERC721(nftContract);
        address nftOwner = nft.ownerOf(tokenId);
        require(nftOwner == msg.sender, "Only NFT owner can list it");

        nfts.push(NFT({
            owner: msg.sender,
            tokenId: tokenId,
            totalSupply: totalSupply
        }));

        emit NFTListed(nfts.length - 1, msg.sender, tokenId, totalSupply);
    }

    function purchaseFraction(uint256 nftId, uint256 amount) external {
        require(nftId < nfts.length, "Invalid NFT ID");
        NFT storage nft = nfts[nftId];
        require(nft.balances[msg.sender] + amount <= nft.totalSupply, "Exceeds total supply");

        uint256 cost = (amount * 1e18 * nft.totalSupply) / nft.totalSupply;
        uint256 fee = (cost * feePercentage) / 10000; // Calculate the fee
        uint256 payment = cost + fee;

        paymentToken.transferFrom(msg.sender, nft.owner, payment - fee); // Send payment to NFT owner
        paymentToken.transferFrom(msg.sender, owner, fee); // Send fee to platform owner

        nft.balances[msg.sender] += amount;

        emit FractionPurchased(nftId, msg.sender, amount);
    }

    function transferFraction(uint256 nftId, address to, uint256 amount) external {
        require(nftId < nfts.length, "Invalid NFT ID");
        NFT storage nft = nfts[nftId];
        require(nft.balances[msg.sender] >= amount, "Insufficient balance");
        nft.balances[msg.sender] -= amount;
        nft.balances[to] += amount;
    }
}
