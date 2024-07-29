const ethers = require('ethers')
const { signer } = require('../config/provider-signer')
const { Router } = require('express')


const Main_contractAddress = process.env.MAIN_CONTRACT_ADDRESS

const { abi } = require('../artifacts/contracts/Main.sol/Main.json')
const mainContractInstance = new ethers.Contract(Main_contractAddress, abi, signer)



const router = Router()


router.route('/registerdriver').post(async (req, res) => {
    try {
        const data = await mainContractInstance.driverToContracts('0x71bE63f3384f5fb98995898A86B02Fb2426c5788')
        // const data = await mainContractInstance.registerDriver()
        console.log(data)

        res.json({
            message: 'Successfully registered as driver.'
        })
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