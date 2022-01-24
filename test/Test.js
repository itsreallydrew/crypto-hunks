const { expect } = require('chai');
const { ethers, artifacts } = require('hardhat');
const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');
// const MerkleProofWrapper = require('MerkleProofWrapper');

describe('Hunkz', () => {
	let contractFactory;
	let contract;
	let user;
	let whitelistUser;
	let owner;
	let dev;
	let merkleProof;

	beforeEach(async function () {
		contractFactory = await hre.ethers.getContractFactory('CryptoHunkz');
		[user, whitelistUser, owner, dev] = await hre.ethers.getSigners();
		contract = await contractFactory.connect(owner).deploy();
		await contract.deployed();
		// merkleProof = await MerkleProofWrapper.new();
	});

	describe('Admin actions', () => {
		it('Should confirm owner as an admin', async function () {
			await contract.connect(owner);
			const result = await contract.admins(owner.address);
			expect(result).to.equal(true);
		});

		it('Should confirm new admin', async function () {
			await contract.connect(owner);
			await contract.setAdmin(dev.address);
			const result = await contract.admins(dev.address);
			expect(result).to.equal(true);
		});

		it('Should set revealed to true', async function () {
			await contract.connect(owner).reveal();
			const result = await contract.revealed();
			expect(result).to.equal(true);
		});

		it('Should allow admin to change the price', async function () {
			await contract.connect(owner).setPrice(100000000);
			let newPrice = await contract.price();
			expect(newPrice).to.equal(Number(100000000));
		});

		it('Should allow admin to change max mint', async function () {
			await contract.connect(owner).setMaxMintAmount(7);
			let result = await contract.maxMintAmount();
			expect(result).to.equal(7);
		});

		it('Should toggle the pause state', async function () {
			await contract.connect(owner).togglePause();
			let result = await contract.mintPaused();
			expect(result).to.equal(true);
		});

		it('Should toggle the sale state', async function () {
			await contract.connect(owner).toggleSaleLive();
			let result = await contract.saleLive();
			expect(result).to.equal(true);
		});

		it('Should increment the total supply', async function () {
			await contract.connect(owner).mintReserve(user.address, 2);
			let result = await contract.totalTokensMinted();
			expect(result).to.equal(2);
		});
		it('Should decrement from the reserve amount', async function () {
			await contract.connect(owner).mintReserve(user.address, 2);
			let result = await contract.RESERVED();
			expect(result).to.equal(18);
		});
	});

	describe('User actions', () => {
		it('Should be able to mint an NFT from the public sale', async function () {
			await contract
				.connect(user)
				.mintHunk(2, { value: ethers.utils.parseEther('.154') });
			const total = await contract.totalTokensMinted();
			expect(total).to.equal(2);
		});

		it('Should be able to check price', async function () {
			let result = await contract.connect(user).price();
			expect(result).to.equal(ethers.utils.parseEther('.077'));
		});

		it('Should allow user to check max mint amount', async function () {
			let result = await contract.connect(user).maxMintAmount();
			expect(result).to.equal(5);
		});

		it('Should allow user to check total supply of collection', async function () {
			let result = await contract.connect(user).TOTAL_SUPPLY();
			expect(result).to.equal(7777);
		});

		it('Should allow user to check total number minted', async function () {
			await contract
				.connect(user)
				.mintHunk(2, { value: ethers.utils.parseEther('.154') });
			let total = await contract.connect(user).totalTokensMinted();
			expect(2).to.equal(total);
		});

		// it('Should be able to mint an NFT from the presale', async function () {
		// 	await contract
		// 		.connect(whitelistUser)
		// 		.mintPresale(whitelistUser.address, 1, {
		// 			value: ethers.utils.parseEther('.08'),
		// 		});
		// 	const total = await contract.getTotalMinted();
		// 	expect(total).to.equal(1);
		// });
	});
});
