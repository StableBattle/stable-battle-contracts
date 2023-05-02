import fs from 'fs';

export default function generateDeployAddressLib(contractAddress : string, contractName : string) {
  const libPath = `./contracts/StableBattle/Init&Updates/${contractName}AddressLib.sol`;
  //Clear generated address libs if they exist
  if (fs.existsSync(libPath)) {
    fs.unlinkSync(libPath)
  }

  //Catalog deployment addresses in the lib file
  fs.writeFileSync(
    libPath,
    `// SPDX-License-Identifier: None

pragma solidity ^0.8.0;

library ${contractName}AddressLib {
  address internal constant ${contractName}Address = ${contractAddress};
}`,
    {flag: "a"}
  )
}