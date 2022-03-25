/* eslint-disable no-undef */
const { MerkleTree } = require('merkletreejs');
const keccak = require('keccak256');

let addresses = [
	'0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266',
	'0x70997970c51812dc3a010c7d01b50e0d17dc79c8',
	'0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc',
	'0x90f79bf6eb2c4f870365e785982e1f101e93b906',
	'0x15d34aaf54267db7d7c367839aaf71a00a2c6a65',
	'0x9965507d1a55bcc2695c58ba16fb37d819b0a4dc',
	'0x976ea74026e726554db657fa54763abd0c3a0aa9',
	'0x14dc79964da2c08b23698b3d3cc7ca32193d9955',
	'0x23618e81e3f5cdf7f54c3d65f7fbc0abf5b21e8f',
	'0xa0ee7a142d267c1f36714e4a8f75612f20a79720',
	'0xbcd4042de499d14e55001ccbb24a551f3b954096',
	'0x71be63f3384f5fb98995898a86b02fb2426c5788',
	'0xfabb0ac9d68b0b445fb7357272ff202c5651694a',
	'0x1cbd3b2770909d4e10f157cabc84c7264073c9ec',
	'0xdf3e18d64bc6a983f673ab319ccae4f1a57c7097',
	'0xcd3b766ccdd6ae721141f452c550ca635964ce71',
	'0x2546bcd3c84621e976d8185a91a922ae77ecec30',
	'0xbda5747bfd65f08deb54cb465eb87d40e51b197e',
	'0xdd2fd4581271e230360230f9337d5c0430bf44c0',
	'0x8626f6940e2eb28930efb4cef49b2d1f2c9c1199',
];

// hashes addresses and maps to new array called leafNodes
const leafNodes = addresses.map((addr) => keccak(addr));
// console.log('leaf nodes:', String(leafNodes));
// creates new merkle tree from leaf nodes, hashes using keccak
const merkleTree = new MerkleTree(leafNodes, keccak, { sortPairs: true });
const rootHash = merkleTree.getHexRoot();

console.log('Whitelist Tree\n', String(merkleTree));
// console.log('Whitelist Tree\n', merkleTree);

// console.log('Root hash:', rootHash.slice(2));
console.log('Root hash:', rootHash);

// grabs the first address from the leafNodes array
const claimingAddress = leafNodes[1];

const hexProof = merkleTree.getHexProof(claimingAddress);

console.log('Proof:', hexProof);

module.exports = {
	merkleTree,
	rootHash,
	hexProof,
};
