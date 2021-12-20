const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Arnies', () => {
	let contractFactory;
	let contract;
	let user;

	beforeEach(async function (params) {
		contractFactory = await ethers.getContractFactory('CryptoArnies');
		[user] = await ethers.getSigners();
		contract = await contractFactory.deploy();
		await contract.deployed();
	});
});
