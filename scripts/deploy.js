const { hexStripZeros } = require('@ethersproject/bytes');

const main = async () => {
	const hunkzContractFactory = await hre.ethers.getContractFactory(
		'CryptoHunkz'
	);
	const hunkzContract = await hunkzContractFactory.deploy(
		'0x70997970c51812dc3a010c7d01b50e0d17dc79c8'
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
