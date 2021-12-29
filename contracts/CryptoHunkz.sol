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

contract CryptoHunkz is
    ERC721Enumerable,
    ReentrancyGuard,
    AccessControl,
    Ownable
{
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using Address for address;

    string private baseURI;
    // string private unrevealedURI;
    // string private baseExtension;

    Counters.Counter private _tokenIdCounter;
    uint256 public totalMinted;
    uint256 public TOTAL_SUPPLY = 5000;
    uint256 public price = 80000000000000000; //price in wei -- 0.08 ether
    uint256 public maxMintAmount = 5;
    uint256 public RESERVED = 20;

    // mapping(address => uint256) public whitelistAmount;
    mapping(address => bool) public admins;

    bool public saleLive;
    bool public revealed;
    bool public mintPaused;

    modifier onlyAdmin() {
        require(admins[msg.sender], "Only admins can call this function");
        _;
    }

    constructor(address _owner) ERC721("CryptoHunkz", "HUNKZ") {
        admins[_owner] = true;
    }

    function mintHunk(uint256 _amount) public payable nonReentrant {
        require(mintPaused == false);
        require(_amount <= 3 && _amount > 0, "Invalid amount");
        require(totalMinted + _amount <= TOTAL_SUPPLY, "Sold out");
        require(msg.value == price.mul(_amount), "Incorrect amount of ether");
        for (uint256 i = 1; i <= _amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(msg.sender, tokenId);
            tokenURI(tokenId);
            totalMinted = totalMinted.add(1);
        }
    }

    function tokensOfOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) return new uint256[](0);
        else {
            uint256[] memory result = new uint256[](tokenCount);
            for (uint256 i = 0; i < tokenCount; i++) {
                result[i] = tokenOfOwnerByIndex(_owner, i);
            }
            return result;
        }
    }

    /********************************************* */
    // IF WE VALIDATE ON FRONTEND DO WE NEED TWO MINT FUNCTIONS?
    /********************************************* */

    // function mintPublic(uint256 amount) public payable nonReentrant {
    //     require(mintPaused == false);
    //     require(amount <= 3, "Limit is 3 per wallet");
    //     require(
    //         totalMinted < TOTAL_SUPPLY,
    //         "Sale has ended. Please visit us on OpenSea"
    //     );
    //     require(msg.value == (price * amount), "Incorrect amount of ether");
    //     for (uint256 i = 1; i <= amount; i++) {
    //         _tokenIdCounter.increment();
    //         uint256 tokenId = _tokenIdCounter.current();
    //         _safeMint(msg.sender, tokenId);
    //         tokenURI(tokenId);
    //         totalMinted = totalMinted.add(1);
    //     }
    // }

    /********************************************* */
    // Only Owner/Admin Functions
    /********************************************* */
    function setAdmin(address _newAdmin) external onlyOwner {
        admins[_newAdmin] = true;
    }

    function mintReserve(address _to, uint256 _amount) public onlyAdmin {
        require(_amount > 0 && _amount <= RESERVED, "Amount is invalid");
        for (uint256 i = 0; i < _amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(_to, tokenId);
            tokenURI(tokenId);
            totalMinted = totalMinted.add(1);
        }
        RESERVED = RESERVED.sub(_amount);
    }

    function reveal() external onlyAdmin {
        revealed = true;
    }

    function setPrice(uint256 _newPrice) external onlyAdmin {
        price = _newPrice;
    }

    function setMaxMintAmount(uint256 _newmaxMintAmount) external onlyAdmin {
        maxMintAmount = _newmaxMintAmount;
    }

    // function setUnrevealedURI(string memory _unrevealedURI) external onlyAdmin {
    //     unrevealedURI = _unrevealedURI;
    // }

    function setBaseURI(string memory _newURI) external onlyAdmin {
        baseURI = _newURI;
    }

    // function setBaseExtension(string memory _newBaseExtension)
    //     public
    //     onlyAdmin
    // {
    //     baseExtension = _newBaseExtension;
    // }

    function togglePause() external onlyAdmin {
        mintPaused = !mintPaused;
    }

    function withdraw() external onlyAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }

    function toggleSaleLive() external onlyAdmin {
        saleLive = !saleLive;
    }

    /********************************************* */
    // OVERRIDES
    /********************************************* */

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
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
