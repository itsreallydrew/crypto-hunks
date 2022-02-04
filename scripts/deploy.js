const { hexStripZeros } = require('@ethersproject/bytes');

const main = async () => {
	const hunkzContractFactory = await hre.ethers.getContractFactory(
		'CryptoHunkz'
	);
	const hunkzContract = await hunkzContractFactory.deploy();
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
