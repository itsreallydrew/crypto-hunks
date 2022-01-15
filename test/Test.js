const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Hunkz', () => {
	let contractFactory;
	let contract;
	let user;
	let whitelistUser;
	let owner;
	let dev;

	beforeEach(async function () {
		contractFactory = await hre.ethers.getContractFactory('CryptoHunkz');
		[user, whitelistUser, owner, dev] = await hre.ethers.getSigners();
		contract = await contractFactory.deploy(owner.address);
		await contract.deployed();
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
			let result = await contract.totalMinted();
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
				.mintHunk(2, { value: ethers.utils.parseEther('.16') });
			const total = await contract.totalMinted();
			expect(total).to.equal(2);
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
