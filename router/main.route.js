const ethers = require('ethers')
const { provider, signer } = require('../config/provider-signer')
const { Router } = require('express')


const Main_contractAddress = process.env.MAIN_CONTRACT_ADDRESS

const { abi } = require('../artifacts/contracts/Main.sol/Main.json')
const fetchMainContract = (signerOrProvider) => new ethers.Contract(Main_contractAddress, abi, signerOrProvider)



const router = Router()


router.route('/registerdriver').post(async (req, res) => {
    const { signer: getSigner } = req.body
    // const mainContractInstance = fetchMainContract(signer)
    try {
        res.json(getSigner)
        // const data = await mainContractInstance.registerDriver()
        // console.log(data)

        // res.json({
        //     message: 'Successfully registered as driver.'
        // })
    }
    catch (err) {
        console.log(err);
        // if (err.info.error.message.includes('alreadyRegistered')) {
        //     return res.json({
        //         message: 'Driver already registered.'
        //     })
        // }
        // else {
        //     res.json({
        //         message: 'Please try again.'
        //     })
        // }
    }
})


module.exports = { router }