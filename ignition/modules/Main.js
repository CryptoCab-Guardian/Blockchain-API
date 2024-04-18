const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("Main", (m) => {
    const main = m.contract("Main", []);
    return { main };
});