const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Arnies', () => {
	let contractFactory;
	let contract;
	let user;
	let whitelistUser;

	beforeEach(async function () {
		contractFactory = await hre.ethers.getContractFactory('CryptoArniez');
		[user, whitelistUser] = await hre.ethers.getSigners();
		contract = await contractFactory.deploy();
		await contract.deployed();
	});

	describe('User actions', () => {
		it('Should be able to mint an NFT from the public sale', async function () {
			await contract
				.connect(user)
				.mintPublic(user.address, 2, { value: ethers.utils.parseEther('.16') });
			const total = await contract.getTotalMinted();
			expect(total).to.equal(2);
		});

		it('Should be able to mint an NFT from the presale', async function () {
			await contract
				.connect(whitelistUser)
				.mintPresale(whitelistUser.address, 1, {
					value: ethers.utils.parseEther('.08'),
				});
			const total = await contract.getTotalMinted();
			expect(total).to.equal(1);
		});
	});
});
