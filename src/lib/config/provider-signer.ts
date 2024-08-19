import ethers from 'ethers'

const API_URL = process.env.HARDHAT_API_URL!
const PRIVATE_KEY = process.env.HARDHAT_PRIVATE_KEY!

export const provider = new ethers.JsonRpcProvider(API_URL)
export const signer = new ethers.Wallet(PRIVATE_KEY, provider)
