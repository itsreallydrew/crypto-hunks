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

import "../OZ_Imports/ERC721Enumerable.sol";

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

contract OwnableDelegateProxy {}
contract OpenSeaProxyRegistry{
    mapping(address => OwnableDelegateProxy) public proxies;
}


contract CryptoHunkz is
    ERC721Enumerable
{
    // using Counters for Counters.Counter;

    bytes32 public merkleRoot;

    string private baseURI;
    // string private unrevealedURI;
    // string private baseExtension;

    uint256 public TOTAL_SUPPLY = 7778; // total supply is 7777 using 7778 for gas optimization
    uint256 public PUBLIC_SUPPLY = 7728; // total public is 7727 using 7728 for gas optimization
    uint256 public price = .077 ether;
    uint256 public maxMintAmount = 6; // max amount is 5
    uint256 public RESERVED = 21; // amount reserved is 20
    string public PROVENANCE; 

    address public proxyRegistryAddress;
    // MAINNET: 0xa5409ec958c83c3f309868babaca7c86dcb077c1
    // RINKEYBY: 0xf57b2c51ded3a29e6891aba85459d600256cf317

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

    constructor() ERC721("CryptoHunkz", "HUNKZ") {
        // admins[_address] = true;
        // admins[msg.sender] = true;
        // merkleRoot = _merkleRoot;
    }

    function whitelistMint(bytes32[] calldata _merkleProof, uint _quantity) public payable {
        require(whiteListActive, 'Whitelist is not active');
        require(!whitelistClaimed[msg.sender], 'Already claimed');
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), 'whitelist user not verified');
        whitelistClaimed[msg.sender] = true;
        mintHunk(_quantity);
    }

    function publicMint(uint _quantity) public payable {
        require(!whiteListActive, 'Whitelist is active');
        mintHunk(_quantity);
    }

    function mintHunk(uint256 _amount) internal {
        require(tx.origin == msg.sender, "Caller must be original address");
        require(saleLive == true, 'Sale is paused');
        require(_amount <  maxMintAmount, "Invalid amount");
        uint totalSupply = _owners.length;
        require(totalSupply < PUBLIC_SUPPLY, "Sold out");
        require(msg.value == price * _amount, "Incorrect amount of ether");
        for (uint256 i = 1; i <= _amount; i++) {
            _safeMint(msg.sender, totalSupply + i);
        }
        // ownerTokens[msg.sender] = _amount;
    }

    /********************************************* */
    // Only Owner/Admin Functions
    /********************************************* */

    function setAdmin(address _newAdmin) external onlyAdmin {
        admins[_newAdmin] = true;
    }

    function mintReserve(address _to, uint256 _amount) public onlyAdmin {
        require(_amount > 0 && _amount <= RESERVED, "Amount is invalid");
        uint totalSupply = _owners.length;
        for (uint256 i = 0; i < _amount; i++) {
            _safeMint(_to, totalSupply + i);
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

    function withdraw() external onlyAdmin {
        payable(msg.sender).transfer(address(this).balance);
    }

    function toggleSaleLive() external onlyAdmin {
        saleLive = !saleLive;
    }

    function toggleProxyState(address _proxyAddress) external onlyAdmin {
        proxyToApproved[_proxyAddress] = !proxyToApproved[_proxyAddress];
    }

    function setRoot(bytes32 _merkleRoot) external onlyAdmin {
        merkleRoot = _merkleRoot;
    }

    function setProxyRegistryAddress(address _proxyRegistryAddress)
        external
        onlyAdmin
    {
        proxyRegistryAddress = _proxyRegistryAddress;
    }


    /********************************************* */
    // OVERRIDES
    /********************************************* */

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function isApprovedForAll(address _owner, address _operator) public view override returns (bool) {
        OpenSeaProxyRegistry proxyRegistry = OpenSeaProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(_owner)) == _operator || proxyToApproved[_operator]) return true;
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
            interfaceId == interfaceId ||
            super.supportsInterface(interfaceId);
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