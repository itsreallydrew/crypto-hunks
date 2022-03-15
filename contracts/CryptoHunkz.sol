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

// import "../OZ_Imports/ERC721Enumerable.sol";

import "../OZ_Imports/ERC721-M.sol";
import "../OZ_Imports/ECDSA.sol";


// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

contract OwnableDelegateProxy {}

contract OpenSeaProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract CryptoHunkz is ERC721 {
    // bytes32 public merkleRoot;

    using ECDSA for bytes32;

    string public baseURI;
    string public hiddenURI;
    string public suffix = ".json";

    uint256 public MAX_SUPPLY = 7779; // total supply is 7777 using 7778 for gas optimization. Because we're having total supply start at 1 we need to increase from 7777 to 7778. And because we don't want to do <= we increase by an additional 1 to get 7779

    uint256 public totalSupply = 1; // look at Jeffrey Scholz - Donkeverse contract for refresher on using this. Modifying how we approach the contract.
    uint256 public PUBLIC_SUPPLY = 7759; // total public is 7727 using 7729 to get rid of double checks and increase an additional because total Minted starting at 1.
    uint256 public price = .077 ether;
    uint256 public maxMintAmount = 6; // max amount is 5
    uint256 public maxWLAmount = 4; // max amount is 3

    uint256 public RESERVED = 21; // amount reserved is 20
    // string public PROVENANCE;

    address public proxyRegistryAddress;
    // MAINNET: 0xa5409ec958c83c3f309868babaca7c86dcb077c1
    // RINKEYBY: 0xf57b2c51ded3a29e6891aba85459d600256cf317

    address private signerAddress;

    mapping(address => bool) public whitelistClaimed;
    mapping(address => bool) public admins;
    // mapping(address => uint) public ownerTokens;
    mapping(address => bool) proxyToApproved;

    bool public saleLive;
    bool public revealed;
    bool public whiteListActive = true;

    modifier onlyAdmin() {
        require(admins[msg.sender], "Only admins can call this function");
        _;
    }

    constructor(string memory _initURI) ERC721("CryptoHunkz", "HUNKZ") {
        admins[msg.sender] = true;
        hiddenURI = _initURI;
    }

    function whitelistMint(bytes calldata _signature, uint256 _quantity)
        external
        payable
    {
        uint256 _totalSupply = totalSupply;
        require(tx.origin == msg.sender, "Caller must be original address");
        require(_totalSupply < MAX_SUPPLY, "sold out");
        require(whiteListActive, "Whitelist is not active");
        require(saleLive == true, "Sale is paused");
        require(_quantity < maxWLAmount, "Max amount is 3");
        require(msg.value == price * _quantity, "Incorrect amount of ether");
        require(!whitelistClaimed[msg.sender], "Already claimed");
        // Switching over to Public signature instead of Merkle Root
        require(signerAddress == keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32", 
                bytes32(uint256(uint160(msg.sender)))))
            .recover(_signature), "Not on list");

        whitelistClaimed[msg.sender] = true;
        for (uint256 i = 1; i <= _quantity; i++) {
            _mint(msg.sender, totalSupply + i);
        }
        unchecked {
        _totalSupply + _quantity;
        }
        _totalSupply = totalSupply;
    }

    function publicMint(uint256 _quantity) external payable {
        require(!whiteListActive, "Whitelist is active");
        require(tx.origin == msg.sender, "Caller must be original address");
        require(saleLive == true, "Sale is paused");
        require(_quantity < maxMintAmount, "Invalid amount");
        require(totalSupply < PUBLIC_SUPPLY, "Sold out");
        require(msg.value == price * _quantity, "Incorrect amount of ether");
        for (uint256 i = 1; i <= _quantity; i++) {
            _mint(msg.sender, totalSupply + i);
        }
    }

    /********************************************* */
    // Only Owner/Admin Functions
    /********************************************* */

    function setAdmin(address _newAdmin) external onlyAdmin {
        admins[_newAdmin] = true;
    }

    function mintReserve(uint256 _amount) external onlyAdmin {
        require(_amount < RESERVED, "Amount is invalid");
        uint256 _totalSupply = totalSupply;
        for (uint256 i = 1; i <= _amount; i++) {
            _mint(_msgSender(), _totalSupply + i);
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

    function setBaseURI(string memory _newURI) external onlyAdmin {
        baseURI = _newURI;
    }

    function toggleWhiteList() external onlyAdmin {
        whiteListActive = !whiteListActive;
    }

    function withdraw() external onlyAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }

    function toggleSaleLive() external onlyAdmin {
        saleLive = !saleLive;
    }

    function toggleProxyState(address _proxyAddress) external onlyAdmin {
        proxyToApproved[_proxyAddress] = !proxyToApproved[_proxyAddress];
    }

    // function setRoot(bytes32 _merkleRoot) external onlyAdmin {
    //     merkleRoot = _merkleRoot;
    // }

    function setProxyRegistryAddress(address _proxyRegistryAddress)
        external
        onlyAdmin
    {
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    /********************************************* */
    // OVERRIDES
    /********************************************* */
    function _mint(address to, uint256 tokenId) internal virtual override {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _owners.push(to);
        emit Transfer(address(0), to, tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false) return hiddenURI;

        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(baseURI, Strings.toString(tokenId), suffix)
                )
                : "";
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool)
    {
        OpenSeaProxyRegistry proxyRegistry = OpenSeaProxyRegistry(
            proxyRegistryAddress
        );
        if (
            address(proxyRegistry.proxies(_owner)) == _operator ||
            proxyToApproved[_operator]
        ) return true;
        return super.isApprovedForAll(_owner, _operator);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == interfaceId || super.supportsInterface(interfaceId);
    }
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
