const ethers = require('ethers')

const API_URL = process.env.HARDHAT_API_URL
const PRIVATE_KEY = process.env.HARDHAT_PRIVATE_KEY

const provider = new ethers.JsonRpcProvider(API_URL)
const signer = new ethers.Wallet(PRIVATE_KEY, provider)

module.exports = { provider, signer }