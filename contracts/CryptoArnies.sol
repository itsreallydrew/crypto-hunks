// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/********************************************* */
// Imports from Open Zeppelin
/********************************************* */

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
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

contract CryptoArnies is ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIDs;
    uint256 public totalMinted = 0;
    uint256 public TOTAL_SUPPLY = 5000;

    // need opensea address

    // modifier arnieOwner(uint256 arnieId) {
    //     require(ownerOf(arnieId) == msg.sender, "Cannot interact with a Arnies you do not own");
    //     _;
    // }

    constructor() public ERC721("CRYPTOARNIES", "ARNIES") {
        console.log("Initial contract test");
    }

    // will need a function to generate an NFT -- mint will be called from inside
    function mint(string memory tokenURI){
        _safeMint();
    }


    // function for burning token

    // function for transferring

    // safetransfer

    //
}
