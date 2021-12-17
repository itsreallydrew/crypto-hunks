const { hexStripZeros } = require('@ethersproject/bytes');

const main = async () => {
	const arniesContractFactory = await hre.ethers.getContractFactory(
		'CryptoArnies'
	);
	const arniesContract = await arniesContractFactory.deploy();
	await arniesContract.deployed();
	console.log('Contract deployed to:', arniesContract.address);
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
