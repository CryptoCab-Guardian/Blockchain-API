import ethers, { ContractRunner } from 'ethers'
import { Router } from 'express'
import { provider, signer } from '../lib/config/provider-signer'


const Main_contractAddress = process.env.MAIN_CONTRACT_ADDRESS as string

import { abi } from '../lib/abis/Main.json'
const fetchMainContract = (signerOrProvider: ContractRunner) => new ethers.Contract(Main_contractAddress, abi, signerOrProvider)



const router = Router()


router.get('/registerdriver', async (req, res) => {
    // const { signer: getSigner } = req.body
    // const mainContractInstance = fetchMainContract(signer)
    try {
        // const data = await mainContractInstance.registerDriver()
        // console.log(data)

        // res.json({
        //     message: 'Successfully registered as driver.'
        // })
    }
    catch (err: any) {
        if (err.info.error.message.includes('alreadyRegistered')) {
            return res.json({
                message: 'Driver already registered.'
            })
        }
        else {
            res.json({
                message: 'Please try again.'
            })
        }
    }
})

export default router
