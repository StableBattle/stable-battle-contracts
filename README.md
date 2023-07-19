# StableBattle Contracts
## How to deploy
- Set PRIVATE_KEY, PUBLIC_KEY and GOERLI_URL in the .env file
- Run forge script script/RegenLibs.s.sol to generate libs
  - If the resulting addresess are already deployed to the network the script will likely error on one of deployments. To alleviate this change the salt value in both script/RegenLibs.s.sol and script/DeploySBGoerli.s.sol
- Run forge script script/DeploySBGoerli.s.sol --fork-url goerli to check if transaction will be successful on the network
- Run forge script script/DeploySBGoerli.s.sol --rpc-url goerli --broadcast

## How to update
- TBD