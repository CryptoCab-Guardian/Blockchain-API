const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("Price_fixing", (m) => {
    const price_fixing = m.contract("Price_fixing", []);
    return { price_fixing };
});