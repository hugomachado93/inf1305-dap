install node and check if is installed with

```bash
node -v
```

Install truffle

```bash
npm install -g truffle
```

Install Ganache

Use ganache memonic phrases in metamask when creating a account, thus linking the ganache to metamask

To run the solidity contracted encountered in the file Dao.sol, run

```bash
truffle migrate
```

After chaging the smart contract, update the contract running

```bash
truffle migrate --reset
```

After run

```bash
npm run dev
```

Will open http://localhost:3000/ where encounters our application
