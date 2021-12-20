// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts@4.4.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.4.0/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.4.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.4.0/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CryptoArniez is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _tokenIdCounter;
    uint256 public totalMinted = 0;
    uint256 public TOTAL_SUPPLY = 5000;
    uint256 public price = 0.08 ether;
    mapping (address => uint) public whitelistAmount;

    bool presaleLive = false;
    bool publicSaleLive = false;

    constructor() ERC721("CryptoArniez", "ARNIEZ") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://cryptoarnies.io/tokens/";
    }

    function mintPresale(address to, uint256 amount) public payable {
        whitelistAmount[msg.sender] = 2;
        require(amount < 3);
        require(whitelistAmount[msg.sender] > 0, "You do not have any reserved mints");
        require(amount <= whitelistAmount[msg.sender], "You have a max of 2 mints");
        require(totalMinted < TOTAL_SUPPLY, "Sale has ended. Please visit us on OpenSea");
        require(msg.value >= price.mul(amount), "Incorrect amount of ether");
        for(uint i = 1; i <= amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(to, tokenId);
            tokenURI(tokenId);
            totalMinted = totalMinted + 1;
        }

    }

    function mintPublic(address to, uint256 amount) public payable{
        require(amount < 3, "Limit is 2 per wallet");
        require(totalMinted < TOTAL_SUPPLY, "Sale has ended. Please visit us on OpenSea");
        require(msg.value >= price, "Incorrect amount of ether");
        require(msg.value >= price.mul(amount), "Incorrect amount of ether");
        for(uint i = 1; i <= amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(to, tokenId);
            tokenURI(tokenId);
            totalMinted = totalMinted + 1;
        }
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
