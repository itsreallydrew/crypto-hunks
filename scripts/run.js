/* eslint-disable no-undef */
/* eslint-disable no-unused-vars */
const { hexStripZeros } = require('@ethersproject/bytes');
const { ethers } = require('ethers');

const main = async () => {
	const hunkzContractFactory = await hre.ethers.getContractFactory(
		'CryptoHunkz'
	);
	const hunkzContract = await hunkzContractFactory.deploy(
		'https://gateway.pinata.cloud/ipfs/QmVH1qf969XKcBzSUvQZtaP6gBzr5fz5wdvEw8m9JmtiWe/hidden.json',
		'0xc1637006969C16FC606468533f6FF941dE2De82D',
		'0xf57b2c51ded3a29e6891aba85459d600256cf317'
	);
	await hunkzContract.deployed();
	console.log('Contract deployed to:', hunkzContract.address);

	let txn = await hunkzContract.toggleSaleLive();
	await txn.wait();

	txn = await hunkzContract.publicMint(5, {
		value: ethers.utils.parseEther('.385'),
	});

	await txn.wait();
	txn = await hunkzContract.publicMint(5, {
		value: ethers.utils.parseEther('.385'),
	});

	await txn.wait();
	txn = await hunkzContract.publicMint(5, {
		value: ethers.utils.parseEther('.385'),
	});

	await txn.wait();
	await txn.wait();
	txn = await hunkzContract.publicMint(5, {
		value: ethers.utils.parseEther('.385'),
	});

	await txn.wait();
	await txn.wait();
	txn = await hunkzContract.publicMint(5, {
		value: ethers.utils.parseEther('.385'),
	});

	await txn.wait();
	await txn.wait();
	txn = await hunkzContract.publicMint(5, {
		value: ethers.utils.parseEther('.385'),
	});

	await txn.wait();
	await txn.wait();
	txn = await hunkzContract.publicMint(5, {
		value: ethers.utils.parseEther('.385'),
	});

	await txn.wait();
	await txn.wait();
	txn = await hunkzContract.publicMint(5, {
		value: ethers.utils.parseEther('.385'),
	});

	await txn.wait();

	txn = await hunkzContract.publicMint(1, {
		value: ethers.utils.parseEther('.077'),
	});

	await txn.wait();

	let total = await hunkzContract.totalSupplyMinted();
	console.log('Total minted is:', Number(total));
};

const runMain = async () => {
	try {
		await main();
		process.exit(0);
	} catch (error) {
		console.log(error);
		process.exit(1);
	}
};

runMain();
