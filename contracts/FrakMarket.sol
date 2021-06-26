// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "hardhat/console.sol";

contract FrakMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemSold;
    uint[] marketItems;
    
    address payable owner;
    uint256 listingPrice = 0.1 ether;
    
    constructor() {
        owner = payable(msg.sender);
    }
    
    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
    }
    
    mapping(uint256 => MarketItem) private idToMarketItem;
    
    event MarketItemCreated(
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price
    );
    
    function getMarketItem(
        uint256 marketItemId
    ) public view returns (MarketItem memory) {
        return idToMarketItem[marketItemId];
    }
    
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price must be greater than 1 Wei");
        require(
            msg.value == listingPrice, 
            "Price must equal Listing price.");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();
        marketItems.push(itemId);
        
        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price
        );
        
        IERC721(nftContract).transferFrom(
            msg.sender, address(this), tokenId);
        
        emit MarketItemCreated(
           itemId,
           nftContract,
           tokenId,
           msg.sender,
           address(0),
           price
        );
    }
    
    function createMarketSale(
        address nftContract,
        uint256 itemId
    ) payable public {
        uint price = idToMarketItem[itemId].price;
        uint tokenId = idToMarketItem[itemId].tokenId;
        require(
            msg.value == price, 
            "Provide the asking price to proceed with purchase");
        
        idToMarketItem[itemId].seller.transfer(msg.value);
        IERC721(nftContract).transferFrom(
            address(this), msg.sender, tokenId);
        idToMarketItem[itemId].owner = payable(msg.sender);
        _itemSold.increment();
        payable(owner).transfer(listingPrice);
    } 

    /// @notice Returns A market item currently on sale
    function fetchMarketItem(
        uint itemId
    ) public view returns (MarketItem memory) {
        MarketItem memory item = idToMarketItem[itemId];
        return item;
    }

    /// @notice Returns ALL market items currently on sale
    function fetchMarketItems(
    ) public view returns (MarketItem[] memory) {
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = _itemIds.current() - _itemSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](
            unsoldItemCount);
        for (uint i = 0; i < itemCount; i++) {
            //  if next item owner is a zero address
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;                
            }            
        }

        return items;
    }

    function fetchMyNFTs(
    ) public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            if(idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if(idToMarketItem[i + 1].owner == msg.sender) {
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }            
        }

        return items;
    }

    
}