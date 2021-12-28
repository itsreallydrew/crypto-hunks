const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Arnies', () => {
	let contractFactory;
	let contract;
	let user;
	let whitelistUser;
	let owner;
	let dev;

	beforeEach(async function () {
		contractFactory = await hre.ethers.getContractFactory('CryptoArniez');
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

		it('Should allow admin to change the price', async function () {
			await contract.connect(owner).setPrice(100000000);
			let newPrice = await contract.price();
			expect(newPrice).to.equal(Number(100000000));
		});
	});

	describe('User actions', () => {
		it('Should be able to mint an NFT from the public sale', async function () {
			await contract
				.connect(user)
				.mintPublic(2, { value: ethers.utils.parseEther('.16') });
			const total = await contract.getTotalMinted();
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
