import ethers, { ContractRunner } from 'ethers'
import { Router } from 'express'


const Price_fixing_contractAddress = process.env.PRICE_FIXING_CONTRACT_ADDRESS as string


import { abi } from '../lib/abis/Price_fixing.json'
const fetchMainContract = (signerOrProvider: ContractRunner) => new ethers.Contract(Price_fixing_contractAddress, abi, signerOrProvider)


const router = Router()



export default router
