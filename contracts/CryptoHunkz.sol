// SPDX-License-Identifier: MIT

/*

 ::::::::  :::::::::  :::   ::: ::::::::: ::::::::::: ::::::::     :::    ::: :::    ::: ::::    ::: :::    ::: ::::::::: 
:+:    :+: :+:    :+: :+:   :+: :+:    :+:    :+:    :+:    :+:    :+:    :+: :+:    :+: :+:+:   :+: :+:   :+:       :+:  
+:+        +:+    +:+  +:+ +:+  +:+    +:+    +:+    +:+    +:+    +:+    +:+ +:+    +:+ :+:+:+  +:+ +:+  +:+       +:+   
+#+        +#++:++#:    +#++:   +#++:++#+     +#+    +#+    +:+    +#++:++#++ +#+    +:+ +#+ +:+ +#+ +#++:++       +#+    
+#+        +#+    +#+    +#+    +#+           +#+    +#+    +#+    +#+    +#+ +#+    +#+ +#+  +#+#+# +#+  +#+     +#+     
#+#    #+# #+#    #+#    #+#    #+#           #+#    #+#    #+#    #+#    #+# #+#    #+# #+#   #+#+# #+#   #+#   #+#      
 ########  ###    ###    ###    ###           ###     ########     ###    ###  ########  ###    #### ###    ### ######### 

*/


pragma solidity ^0.8.0;

/********************************************* */
// Imports from Open Zeppelin
/********************************************* */

// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Holder.sol";
// import "@openzeppelin/contracts/introspection/IERC165.sol";
// import "@openzeppelin/contracts/introspection/ERC165.sol";
// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";
// import "@openzeppelin/contracts/security/Pausable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

contract OwnableDelegateProxy {}
contract OpenSeaProxyRegistry{
    mapping(address => OwnableDelegateProxy) public proxies;
}


contract CryptoHunkz is
    ERC721,
    ReentrancyGuard,
    Ownable
{
    using Counters for Counters.Counter;

    bytes32 public merkleRoot;

    string private baseURI;
    // string private unrevealedURI;
    // string private baseExtension;

    Counters.Counter private _tokenIdCounter;
    uint256 public TOTAL_SUPPLY = 7777;
    uint256 public price = .077 ether;
    uint256 public maxMintAmount = 4;
    uint256 public RESERVED = 20;
    string public PROVENANCE; 

    // address public proxyRegistryAddress;
    // MAINNET: 0xa5409ec958c83c3f309868babaca7c86dcb077c1
    // RINKEYBY: 0xf57b2c51ded3a29e6891aba85459d600256cf317

    mapping(address => bool) public whitelistClaimed;
    mapping(address => bool) public admins;
    mapping(address => uint) public ownerTokens;
    mapping(address => bool) proxyToApproved;

    bool public saleLive = true;
    bool public revealed;
    bool public mintPaused;
    bool public whiteListActive = true;

    modifier onlyAdmin() {
        require(admins[msg.sender], "Only admins can call this function");
        _;
    }

    constructor(address _address, bytes32 _merkleRoot) ERC721("CryptoHunkz", "HUNKZ") {
        admins[_address] = true;
        // admins[msg.sender] = true;
        merkleRoot = _merkleRoot;

        // _tokenIdCounter.increment();
    }

    function whitelistMint(bytes32[] calldata _merkleProof, uint _quantity) public payable nonReentrant {
        require(whiteListActive, 'Whitelist is not active');
        require(!whitelistClaimed[msg.sender], 'Already claimed');
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), 'whitelist user not verified');
        whitelistClaimed[msg.sender] = true;
        mintHunk(_quantity);
    }

    function publicMint(uint _quantity) public payable nonReentrant {
        require(!whiteListActive, 'Whitelist is active');
        mintHunk(_quantity);
    }

    function mintHunk(uint256 _amount) internal {
        require(tx.origin == msg.sender, "Caller must be original address");
        require(mintPaused == false, 'Sale is paused');
        require(_amount <  maxMintAmount, "Invalid amount");
        uint totalMinted = _tokenIdCounter.current() + _amount;
        require(totalMinted <= TOTAL_SUPPLY, "Sold out");
        require(msg.value == price * _amount, "Incorrect amount of ether");
        for (uint256 i = 1; i <= _amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();
            _safeMint(msg.sender, tokenId);
            tokenURI(tokenId);
        }
        ownerTokens[msg.sender] = _amount;
    }

    function totalTokensMinted() public view returns (uint) {
        return _tokenIdCounter.current();
    }
    // function tokensOfOwner(address _owner)
    //     external
    //     view
    //     returns (uint256[] memory)
    // {
    //     uint256 tokenCount = balanceOf(_owner);
    //     if (tokenCount == 0) return new uint256[](0);
    //     else {
    //         uint256[] memory result = new uint256[](tokenCount);
    //         for (uint256 i = 0; i < tokenCount; i++) {
    //             result[i] = tokenOfOwnerByIndex(_owner, i);
    //         }
    //         return result;
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
        }
        RESERVED = RESERVED -= _amount;
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

    function toggleWhiteList() external onlyAdmin {
        whiteListActive = !whiteListActive;
    }

    function togglePause() external onlyAdmin {
        mintPaused = !mintPaused;
    }

    function withdraw() external onlyAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }

    function toggleSaleLive() external onlyAdmin {
        saleLive = !saleLive;
    }

    function toggleProxyState(address _proxyAddress) public onlyAdmin {
        proxyToApproved[_proxyAddress] = !proxyToApproved[_proxyAddress];
    }

    function setRoot(bytes32 _merkleRoot) public onlyAdmin {
        merkleRoot = _merkleRoot;
    }


    /********************************************* */
    // OVERRIDES
    /********************************************* */

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    // function isApprovedForAll(address _owner, address _operator) public view override returns (bool) {
    //     OpenSeaProxyRegistry proxyRegistry = OpenSeaProxyRegistry(proxyRegistryAddress);
    //     if (address(proxyRegistry.proxies(_owner)) == _operator || proxyToApproved[_operator]) return true;
    //     return super.isApprovedForAll(_owner, _operator);
    // }

    // function supportsInterface(bytes4 interfaceId)
    //     public
    //     view
    //     virtual
    //     override
    //     returns (bool)
    // {
    //     return
    //         interfaceId == type(IAccessControl).interfaceId ||
    //         super.supportsInterface(interfaceId);
    // }
}


/*
    :::::::::  :::::::::: ::::::::  :::::::::  :::::::::: :::::::: ::::::::::: 
    :+:    :+: :+:       :+:    :+: :+:    :+: :+:       :+:    :+:    :+:      
    +:+    +:+ +:+       +:+        +:+    +:+ +:+       +:+           +:+       
    +#++:++#:  +#++:++#  +#++:++#++ +#++:++#+  +#++:++#  +#+           +#+        
    +#+    +#+ +#+              +#+ +#+        +#+       +#+           +#+         
    #+#    #+# #+#       #+#    #+# #+#        #+#       #+#    #+#    #+#          
    ###    ### ########## ########  ###        ########## ########     ###           

                    ::::::::::: :::    ::: :::::::::: 
                        :+:     :+:    :+: :+:         
                        +:+     +:+    +:+ +:+          
                        +#+     +#++:++#++ +#++:++#      
                        +#+     +#+    +#+ +#+            
                        #+#     #+#    #+# #+#             
                        ###     ###    ### ##########       

                :::::::::     :::       :::   :::   ::::::::: 
                :+:    :+:  :+: :+:    :+:+: :+:+:  :+:    :+: 
                +:+    +:+ +:+   +:+  +:+ +:+:+ +:+ +:+    +:+  
                +#++:++#+ +#++:++#++: +#+  +:+  +#+ +#++:++#+    
                +#+       +#+     +#+ +#+       +#+ +#+           
                #+#       #+#     #+# #+#       #+# #+#            
                ###       ###     ### ###       ### ###             

*/