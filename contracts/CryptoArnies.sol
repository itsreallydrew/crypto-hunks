// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/********************************************* */
// Imports from Open Zeppelin
/********************************************* */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

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
// import "@openzeppelin/contracts/utils/Strings.sol";
// import "@openzeppelin/contracts/security/Pausable.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

// import "../OZ_Imports/ERC721Enumberable.sol";

contract CryptoArniez is
    ERC721Enumerable,
    ReentrancyGuard,
    AccessControl,
    Ownable
{
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using Address for address;

    string private baseURI;
    string private unrevealedURI;
    string private baseExtension;

    Counters.Counter private _tokenIdCounter;
    uint256 public totalMinted;
    uint256 public TOTAL_SUPPLY = 5000;
    uint256 public price = 0.08 ether;
    uint256 public maxMintAmount = 5;
    uint256 public RESERVED_ARNIES = 20;

    mapping(address => uint256) public whitelistAmount;
    mapping(address => mapping(uint256 => uint256)) public nftHolders;
    mapping(address => bool) public admins;

    bool presaleLive;
    bool publicSaleLive;
    bool revealed;
    bool mintPaused;

    modifier onlyAdmin() {
        require(admins[msg.sender], "Only admins can call this function");
        _;
    }

    constructor(address _owner) ERC721("CryptoArniez", "ARNIEZ") {
        admins[_owner] = true;
    }

    function setAdmin(address _newAdmin) external onlyOwner {
        admins[_newAdmin] = true;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function mintPresale(uint256 amount) public payable nonReentrant {
        require(mintPaused == false);
        require(amount <= 3 && amount > 0, "Invalid amount");
        require(totalMinted + amount <= TOTAL_SUPPLY, "Sold out");
        require(msg.value == price.mul(amount), "Incorrect amount of ether");
        for (uint256 i = 1; i <= amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(msg.sender, tokenId);
            tokenURI(tokenId);
            totalMinted = totalMinted.add(1);
        }
    }

    function mintPublic(uint256 amount) public payable nonReentrant {
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
            totalMinted = totalMinted.add(1);
        }
    }

    function getTotalMinted() public view returns (uint256) {
        return totalMinted;
    }

    /********************************************* */
    // Only Owner Functions
    /********************************************* */

    function reveal() external onlyAdmin {
        revealed = true;
    }

    function setPrice(uint256 _newPrice) external onlyAdmin {
        price = _newPrice;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) external onlyAdmin {
        maxMintAmount = _newmaxMintAmount;
    }

    function setUnrevealedURI(string memory _unrevealedURI) external onlyAdmin {
        unrevealedURI = _unrevealedURI;
    }

    function setBaseURI(string memory _newURI) external onlyAdmin {
        baseURI = _newURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyAdmin
    {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) external onlyAdmin {
        mintPaused = _state;
    }

    function withdraw() external onlyAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }

    function togglePresaleLive() external onlyAdmin {
        presaleLive = !presaleLive;
    }

    function togglePublicSaleLive() external onlyAdmin {
        publicSaleLive = !publicSaleLive;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC721Enumerable)
        returns (bool)
    {
        return
            interfaceId == type(IAccessControl).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
