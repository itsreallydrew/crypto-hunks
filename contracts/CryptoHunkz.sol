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

import "../OZ_Imports/ERC721-M.sol";
import "../OZ_Imports/ECDSA.sol";
import "hardhat/console.sol";

contract OwnableDelegateProxy {}

contract OpenSeaProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract CryptoHunkz is ERC721 {

    using ECDSA for bytes32;

    string public baseURI;
    string public hiddenURI;
    string public suffix = ".json";

    uint256 public MAX_SUPPLY = 7778; // total supply is 7777 using 7778 for gas optimization. Because we're having total supply start at 1 we need to increase from 7777 to 7778.
    uint256 private totalSupply = 1; // look at Jeffrey Scholz - Donkeverse contract for refresher on using this. Modifying how we approach the contract.
    uint256 public PUBLIC_SUPPLY = 7758; // total public is 7758 using 7758 to get rid of double checks and increase an additional because total Minted starting at 1.
    
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
    mapping(address => bool) proxyToApproved;

    bool public saleLive;
    bool public revealed;
    bool public whiteListActive;

    modifier onlyAdmin() {
        require(admins[msg.sender], "Only admins can call this function");
        _;
    }

    constructor(string memory _initURI, address _signingAddress, address _proxy) ERC721("CryptoHunkz", "HUNKZ") {
        admins[msg.sender] = true;
        hiddenURI = _initURI;
        signerAddress = _signingAddress;
        proxyRegistryAddress = _proxy;
    }

    function whitelistMint(bytes calldata _signature, uint256 _quantity)
        external
        payable
    {
        uint256 _totalSupply = totalSupply;
        require(tx.origin == msg.sender, "Caller must be original address");
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
        for (uint256 i = 0; i < _quantity; i++) {
            _mint(msg.sender, _totalSupply);
            unchecked {
                _totalSupply++;
            }
        }
        totalSupply = _totalSupply;
    }

    function publicMint(uint256 _quantity) external payable {
        uint256 _totalSupply = totalSupply;
        require(!whiteListActive, "Whitelist is active");
        require(msg.sender == tx.origin, "Caller must be original address");
        require(saleLive == true, "Sale is paused");
        require(_quantity < maxMintAmount, "Invalid amount");
        require(totalSupply < PUBLIC_SUPPLY, "Sold out");
        require(msg.value == price * _quantity, "Incorrect amount of ether");
        for (uint256 i = 0; i < _quantity; i++) {
            _mint(msg.sender, _totalSupply);
            console.log("NFT w/ id: %s has been minted", _totalSupply);
            unchecked {
                _totalSupply++;
            }
        }
        totalSupply = _totalSupply;
    }

    function totalSupplyMinted() external view returns(uint256) {
        return totalSupply - 1;
    }

    /********************************************* */
    // Only Owner/Admin Functions
    /********************************************* */

    function setAdmin(address _newAdmin) external onlyAdmin {
        admins[_newAdmin] = true;
    }

    // function removeAdmin(address _oldAdmin) external onlyAdmin {
    //     checkAdmin(_oldAdmin) ?
    //     delete admins[_oldAdmin]: revert();
    // }




    function mintReserve(uint256 _amount, address _to) external onlyAdmin {
        require(_amount < RESERVED, "Amount is invalid");
        uint256 _totalSupply = totalSupply;
        for (uint256 i = 0; i < _amount; i++) {
            _mint(_to, _totalSupply);
            unchecked {
                _totalSupply++;
            }
        }
        RESERVED = RESERVED -= _amount;
        totalSupply = _totalSupply;

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

    function setSignerAddress(address _signerAddress) external onlyAdmin {
        signerAddress = _signerAddress;
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
