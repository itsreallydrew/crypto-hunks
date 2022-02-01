const { hexStripZeros } = require('@ethersproject/bytes');

const main = async () => {
	const hunkzContractFactory = await hre.ethers.getContractFactory(
		'CryptoHunkz'
	);
	const hunkzContract = await hunkzContractFactory.deploy(
		'0x9A66815f864b433C044da32CA7d21abf94017Fce',
		'0xa2720bf73072150e787f41f9ca5a9aaf9726d96ee6e786f9920eae0a83b2abed'
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
