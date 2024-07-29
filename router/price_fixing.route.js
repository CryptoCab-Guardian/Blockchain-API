const ethers = require('ethers')
const { signer } = require('../config/provider-signer')

const Price_fixing_contractAddress = process.env.PRICE_FIXING_CONTRACT_ADDRESS

const { abi } = require('../artifacts/contracts/Price_fixing.sol/Price_fixing.json')
const priceFixingContractInstance = new ethers.Contract(Price_fixing_contractAddress, abi, signer)

