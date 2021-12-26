// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/********************************************* */
// Imports from Open Zeppelin
/********************************************* */

import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Holder.sol";
// import "@openzeppelin/contracts/introspection/IERC165.sol";
// import "@openzeppelin/contracts/introspection/ERC165.sol";
// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/utils/EnumerableSet.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";
// import "@openzeppelin/contracts/security/Pausable.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

import "../OZ_Imports/ERC721Enumberable.sol";

contract CryptoArniez is ERC721Enumerable, ReentrancyGuard {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using Address for address;

    string private baseURI;
    string private unrevealedURI;

    Counters.Counter private _tokenIdCounter;
    uint256 public totalMinted = 0;
    uint256 public TOTAL_SUPPLY = 5000;
    uint256 public price = 0.08 ether;
    uint256 public maxMintAmount = 3;

    mapping(address => uint256) public whitelistAmount;
    mapping(address => mapping(uint256 => uint256)) public nftHolders;

    bool presaleLive;
    bool publicSaleLive;
    bool revealed = false;
    bool mintPaused = true;

    constructor() ERC721("CryptoArniez", "ARNIEZ") {}

    function _baseURI() internal pure override returns (string memory) {
        return baseURI;
    }

    function mintPresale(uint256 amount) public payable {
        require(mintPaused == false);
        require(amount <= 3 && amount > 0, "Please choose a valid amount");
        whitelistAmount[msg.sender] = amount;
        require(
            whitelistAmount[msg.sender] > 0,
            "You do not have any reserved mints"
        );
        // require(
        //     amount <= whitelistAmount[msg.sender],
        //     "You have a max of 2 mints"
        // );
        require(
            totalMinted + amount < TOTAL_SUPPLY,
            "Sale has ended. Please visit us on OpenSea"
        );
        require(msg.value == (price * amount), "Incorrect amount of ether");
        for (uint256 i = 1; i <= amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(msg.sender, tokenId);
            tokenURI(tokenId);
            totalMinted = totalMinted + 1;
        }
    }

    function mintPublic(uint256 amount) public payable {
        require(mintPaused == false);
        require(amount <= 3, "Limit is 3 per wallet");
        require(
            totalMinted < TOTAL_SUPPLY,
            "Sale has ended. Please visit us on OpenSea"
        );
        require(msg.value == (price * amount), "Incorrect amount of ether");
        for (uint256 i = 1; i <= amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(msg.sender, tokenId);
            tokenURI(tokenId);
            totalMinted = totalMinted + 1;
        }
    }

    function getTotalMinted() public view returns (uint256) {
        return totalMinted;
    }



    // Only Owner Functions
    function reveal() public onlyOwner {
        revealed = true;
    }
    
    function setPrice(uint256 _newPrice) public onlyOwner {
        price = _newPrice;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }
    
    function setUnrevealedURI(string memory _unrevealedURI) public onlyOwner {
        unrevealedURI = _unrevealedURI;
    }

    function setBaseURI(string memory _newURI) public onlyOwner {
        baseURI = _newURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        mintPaused = _state;
    }

    function withdraw() public onlyOwner {
        uint256 bal = address(this).bal;
        payable(msg.sender).transfer(bal);
    }

}

