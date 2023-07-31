# StableBattle Contracts
## How to deploy
- Set PRIVATE_KEY, PUBLIC_KEY and GOERLI_URL in the .env file
- Run forge script script/RegenLibs.s.sol to generate libs
  - If the resulting addresess are already deployed to the network the script will likely error on one of deployments. To alleviate this change the salt value in both script/RegenLibs.s.sol and script/DeploySBGoerli.s.sol
- Run forge script script/DeploySBGoerli.s.sol --fork-url goerli to check if transaction will be successful on the network
- Run forge script script/DeploySBGoerli.s.sol --rpc-url goerli --broadcast

## How to update
Updates a usually done in one of three ways.
- Updating the storage of a contract through a special contract (simmilar to the DiamondInit.sol)
- Updating the facets of a contract
- Combination of both
It's done in a way simmilar to the deployment procedure.
1. Write a storage altering contract
2. Either compare the current bytecode of each facet to the one in the network and only change altered ones or simply replace all the contract factes with the new ones. **Make sure** to do an exception for DiamondCut facet. Carless removal or replacement of it's functions may render the contract unupgradeable.
3. Execute diamondCut(facets, storageUpgradeAddress, storageUpgradeCall) function from authorised address. Where 
- Facets is an array of tuples (facetAddress, facetCutAction, functionSelectors)
 - facetCutAction - is either Add, Replace or Remove which respectively
  - Add new functions
  - Replace existing functions
  - Remove old functions
 - facetAddress is the new address of the facet or address(0) if facetCutAction is Remove
- functionSelectors are selectors of the functions to be added/replaced/removed

Let's look at an example.
We have the old facet with 3 functions 
- funcToStay
- funcToRemove
- funcToReplace
And a new one with 3 functions
- funcToStay
- funcToAdd
- funToReplace
As evident from the function names we want to remove one function, replace another and add yet another, while not changing funcToStay.
To do this we will need a facets array that looks like this:
[
  (newFacetAddress, FacetCutAction.Add, [selector(funcToAdd)]),
  (newFacetAddress, FacetCutAction.Replace, [selector(funcToReplace)]),
  (address(0), FacetCutAction.Remove, [selector(funcToRemove)])
]
It is a good prctice to replace even the function that ***should*** be working the same since it's usually hard do guess their behaviour if some dependency or modifiers have been altered.
Also a second notice to **always** make additional checks and exceptions for DiamondCut functions. Otherwise the contract may be rendered **permanently** unupgradable.

You can see an example of an upgrade function in the UpdateStableBattle.s.sol file.