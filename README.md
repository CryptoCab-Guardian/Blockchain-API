# Steps to Deploy the Main contract

Used Hardhat Ignition modules that deploys that Main and Price_fixing contracts.

First spin up the hardhat node:

```
 npx hardhat node
```

Run the following commands to deploy the contracts:

```
npx hardhat ignition deploy ignition/modules/Main.js --network localhost
npx hardhat ignition deploy ignition/modules/Price_fixing.js --network localhost
```

For further queries regarding deployment refer to the hardhat documentation!
