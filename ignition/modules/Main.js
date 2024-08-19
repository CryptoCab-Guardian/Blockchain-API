const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

require('dotenv').config()

module.exports = buildModule("Main", (m) => {
    const main = m.contract("Main", [process.env.PRICE_FIXING_CONTRACT_ADDRESS]);
    
    return { main };
});