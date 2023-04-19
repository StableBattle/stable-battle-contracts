import hre, { ethers } from "hardhat";
import { FacetCutAction } from "./libraries/diamond";
import { SBD as newSBAddress } from "./config/goerli/main-contracts";
import { SBD as newSBAddressHH } from "./config/hardhat/main-contracts";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber, ContractTransaction } from "ethers";

const fake006 = "0x410DF018E0e3FAA78595430D3fb97C58336d7c77";
const real006 = "0xC0662fAee7C84A03B1e58d60256cafeeb08Ab85d";

export default async function migrateSB006(SB006Address : string) {
//Stop ERC1155 mints and transfers
  const SB006 = await ethers.getContractAt("IStableBattle", SB006Address);
  const cut = [];
  //disable transfer, transfer batch & mintKnight
  const safeTransferFromSelector = "0xf242432a";
  const safeBatchTransferFromSelector = "0x2eb2c2d6";
  const mintKnightSelector = "0xba837765";
  cut.push({
    facetAddress: ethers.constants.AddressZero,
    action: FacetCutAction.Remove,
    functionSelectors: [safeTransferFromSelector, safeBatchTransferFromSelector, mintKnightSelector]
  });
  const StakeTransferContract = await ethers.getContractFactory("StakeTransfer");
  const stakeTransfer = await StakeTransferContract.deploy(
    hre.network.name == "goerli" ? newSBAddress : newSBAddressHH);
  await stakeTransfer.deployed();
  const functionCall = stakeTransfer.interface.encodeFunctionData('transferStake');
  let tx : ContractTransaction;
  if(hre.network.name === "hardhat") {
    await impersonateAccount(await SB006.owner());
    const owner = await ethers.getSigner(await SB006.owner());
    tx = await SB006.connect(owner).diamondCut(cut, stakeTransfer.address, functionCall);
  } else {
    tx = await SB006.diamondCut(cut, stakeTransfer.address, functionCall);
  }
  console.log('SBD cut tx: ', tx.hash);
  const receipt = await tx.wait();
  if (!receipt.status) {
    throw Error(`SBD upgrade failed: ${tx.hash}`)
  }
  console.log('Completed StableBattle 0.0.6 diamond cut');

//Transfer knight data
  const newSB = await ethers.getContractAt(
    "IStableBattle", 
    hre.network.name == "goerli" ? newSBAddress : newSBAddressHH)
  const total = await SB006.getKnightsMintedTotal();
  console.log('Knight data to migrate: ', total.toString());
  for(let from = BigNumber.from(0); total.gt(from); from = from.add(300)) {
    const to = total.lt(from.add(300)) ? total : from.add(300);
    const tx = await newSB.debugInheritKnightOwnership(SB006.address, from, to);
    tx.wait();
    console.log(`Transferred knight mints ${from} to ${to}: ${tx.hash}`);
  }
  console.log('Completed knight migration');
}

migrateSB006(fake006).catch((error) => {
  console.error(error);
  process.exitCode = 1;
});