// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC721.sol";


contract Market {

  enum ListingStatus {
    Active,
    Sold,
    Cancelled
  }

  struct Listing {
    ListingStatus status;
    address seller;
    address token;
    uint tokentId;
    uint price;
  }

  uint private _listingId = 0;
  mapping(uint => Listing) private _listings;

  function listTokens(address token, uint tokenId, uint price) external {
    IERC721(token).transferFrom(msg.sender, address(this), tokenId);

    Listing memory listing = Listing(
      ListingStatus.Active,
      msg.sender,
      token,
      tokenId,
      price
    );

    // increace counter
    _listingId++;
    _listings[_listingId] = listing;
  }

  function buyToken(uint listingId) external payable {
    Listing storage listing = _listings[listingId];

    require(listing.status == ListingStatus.Active, "This NFT already sold");
    require(msg.sender != listing.seller, "Seller cannot buy his own NFT");
    require(msg.value >= listing.price, "Not enought amount of ether");

    // msg.value = value ether from sender (wai)

    IERC721(listing.token).transferFrom(address(this), msg.sender, listing.tokentId);
    payable(listing.seller).transfer(listing.price);
  }

  function cancel(uint listingId) public {
    Listing storage listing = _listings[listingId];

    require(listing.status == ListingStatus.Active, "Listing is not active");
    require(msg.sender == listing.seller, "Only seller can cancel listing");

    listing.status = ListingStatus.Cancelled;

    IERC721(listing.token).transferFrom(address(this), msg.sender, listing.tokentId);
  }
}