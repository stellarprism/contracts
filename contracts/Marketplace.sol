// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Marketplace is Ownable, IERC721Receiver {
    struct Planet {
        uint256 tokenId;
        address payable seller;
        uint256 price;
    }

    event Deposit(address seller, uint256 tokenId, uint256 price);
    event Withdraw(address seller, uint256 tokenId);
    event Buy(address buyer, address seller, uint256 tokenId, uint256 price);

    IERC721 public token;
    uint256 feesPercent;

    mapping(uint256 => bool) public isOnSale;
    mapping(uint256 => Planet) public tokenIdToPlanet;

    constructor(IERC721 _token, uint256 _feesPercent) {
        token = _token;

        setFeesPercent(_feesPercent);
    }

    function deposit(uint256 tokenId, uint256 price) public {
        address seller = _msgSender();

        require(price != 0, "Marketplace: price cannot be zero");
        require(token.ownerOf(tokenId) == seller, "Marketplace: only token's owner can deposit it");

        token.safeTransferFrom(seller, address(this), tokenId);

        isOnSale[tokenId] = true;
        tokenIdToPlanet[tokenId] = Planet({
            tokenId: tokenId,
            seller: payable(seller),
            price: price
        });

        emit Deposit(seller, tokenId, price);
    }

    function withdraw(uint256 tokenId) public {
        Planet storage planet = tokenIdToPlanet[tokenId];

        require(planet.tokenId == tokenId, "Marketplace: token is not currently on sale");
        require(_msgSender() == planet.seller, "Marketplace: only planet's seller can withdraw");

        token.safeTransferFrom(address(this), planet.seller, tokenId);

        _deletePlanet(planet);

        emit Withdraw(_msgSender(), tokenId);
    }

    function buy(uint256 tokenId) public payable {
        address buyer = msg.sender;
        uint256 price = msg.value;

        Planet storage planet = tokenIdToPlanet[tokenId];
        address payable seller = planet.seller;

        _requireOnSale(tokenId);
        require(buyer != seller, "Marketplace: seller can't buy its own planet");
        require(price >= planet.price, "Marketplace: given price is not enough");

        token.safeTransferFrom(address(this), buyer, tokenId);

        uint256 fees = price * feesPercent / 100;
        uint256 paidToSeller = price - fees;

        seller.transfer(paidToSeller);

        _deletePlanet(planet);

        emit Buy(buyer, seller, tokenId, price);
    }

    function collectFees() public onlyOwner {
        uint256 balance = address(this).balance;

        require(balance != 0, "Marketplace: no fees to collect");

        payable(owner()).transfer(address(this).balance);
    }

    function setFeesPercent(uint256 value) public onlyOwner {
        require(feesPercent != value, "Marketplace: new value can't be the same as current value");
        require(value != 0, "Marketplace: value must not be zero");
        require(value <= 100, "Marketplace: value must below 100");

        feesPercent = value;
    }
    
    function onERC721Received(
        address operator,
        address,
        uint256,
        bytes calldata
    ) external view override returns (bytes4)
    {
      require(address(this) == operator, "Marketplace: only marketplace can use the transfer");

      return Marketplace.onERC721Received.selector;
    }

    function _requireOnSale(uint256 tokenId) private view {
        require(isOnSale[tokenId], "Marketplace: token is not currently on sale");
    }

    function _deletePlanet(Planet storage planet) private {
        uint256 tokenId = planet.tokenId;

        delete isOnSale[tokenId];
        delete tokenIdToPlanet[tokenId];
    }
}