import hre, { network } from "hardhat";
import "@nomiclabs/hardhat-ethers";
import { IERC20Mintable, IERC20Metadata } from "../typechain-types";
import { USDT as USDT_address, USDC as USDC_address } from "./config/sb-init-addresses";

async function decimalsTest () {
  const accounts = await hre.ethers.getSigners();

  const USDT: IERC20Mintable = await hre.ethers.getContractAt('IERC20Mintable', USDT_address[hre.network.name]);
  const USDC: IERC20Mintable = await hre.ethers.getContractAt('IERC20Mintable', USDC_address[hre.network.name]);

  const usdtMetadata: IERC20Metadata = await hre.ethers.getContractAt('IERC20Metadata', USDT_address[hre.network.name]);
  const usdcMetadata: IERC20Metadata = await hre.ethers.getContractAt('IERC20Metadata', USDC_address[hre.network.name]);

  const usdtDecimals = await usdtMetadata.decimals();
  const usdcDecimals = await usdcMetadata.decimals();

  const usdtBalanceBefore = await USDT.balanceOf(accounts[0].address);
  const usdcBalanceBefore = await USDC.balanceOf(accounts[0].address);
  
  console.log(`USDT balance before: ${usdtBalanceBefore}`);
  console.log(`USDC balance before: ${usdcBalanceBefore}`);
  
  const usdtMintTx = await USDT.mint(accounts[0].address, 10000 * (10 ** usdtDecimals));
  const usdcMintTx = await USDC.mint(accounts[0].address, 10000 * (10 ** usdcDecimals));

  usdtMintTx.wait;
  usdcMintTx.wait;

  const usdtBalanceAfter = await USDT.balanceOf(accounts[0].address);
  const usdcBalanceAfter = await USDC.balanceOf(accounts[0].address);

  console.log(`USDT balance after: ${usdtBalanceAfter}`);
  console.log(`USDC balance after: ${usdcBalanceAfter}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
decimalsTest().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

export default decimalsTest;