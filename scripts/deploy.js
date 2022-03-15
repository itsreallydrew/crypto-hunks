/* eslint-disable no-unused-vars */
/* eslint-disable no-undef */
const { hexStripZeros } = require('@ethersproject/bytes');

const main = async () => {
	const hunkzContractFactory = await hre.ethers.getContractFactory(
		'CryptoHunkz'
	);
	const hunkzContract = await hunkzContractFactory.deploy(
		'https://gateway.pinata.cloud/ipfs/QmVH1qf969XKcBzSUvQZtaP6gBzr5fz5wdvEw8m9JmtiWe/hidden.json'
	);
	await hunkzContract.deployed();
	console.log('Contract deployed to:', hunkzContract.address);
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
