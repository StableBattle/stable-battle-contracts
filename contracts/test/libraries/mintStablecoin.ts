import hre from "hardhat";
import "@nomiclabs/hardhat-ethers";
import { IERC20Mintable, IERC20Metadata } from "../../../typechain-types";
import { USDT as USDT_address, USDC as USDC_address, AAVE } from "../../../scripts/config/sb-init-addresses";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

interface CoinInterface {
  contract: IERC20Mintable;
  metadata: IERC20Metadata;
}

export async function mintStablecoin(
  account: SignerWithAddress,
  coinAddress: string,
  amount: number)
{
  const Coin : CoinInterface = {
    contract: await hre.ethers.getContractAt('IERC20Mintable', coinAddress),
    metadata: await hre.ethers.getContractAt('IERC20Metadata', coinAddress),
  }

  const coinDecimals = await Coin.metadata.decimals();
  const mintTx = await Coin.contract.mint(account.address, amount * (10 ** coinDecimals));
  mintTx.wait;

  let coinName : string;
  switch(coinAddress) {
    case(USDT_address[hre.network.name]) : coinName = "USDT";
    case(USDC_address[hre.network.name]) : coinName = "USDC";
    default : coinName = "stablecoins"
  }
  console.log(`Minted ${amount} ${coinName} to ${account.address}`)
}

export async function approveStablecoin(
  account: SignerWithAddress,
  coinAddress: string,
  spender: string, 
  amount: number) 
{
  const Coin : CoinInterface = {
    contract: await hre.ethers.getContractAt('IERC20Mintable', coinAddress),
    metadata: await hre.ethers.getContractAt('IERC20Metadata', coinAddress),
  }

  const coinDecimals = await Coin.metadata.decimals();

  const coinContractForAccount = Coin.contract.connect(account);
  const mintTx = await coinContractForAccount.approve(spender, amount * (10 ** coinDecimals));
  mintTx.wait;

  let coinName : string;
  switch(coinAddress) {
    case(USDT_address[hre.network.name]) : coinName = "USDT";
    case(USDC_address[hre.network.name]) : coinName = "USDC";
    default : coinName = "stablecoins"
  }
  let spenderName : string;
  switch(spender) {
    case(AAVE[hre.network.name]) : spenderName = "AAVE";
    default : spenderName = spender;
  }
  console.log(`Appoved ${amount} ${coinName} from ${account.address} to ${spenderName}`)
}

export async function mintUSDT(account: SignerWithAddress, amount: number) {
  mintStablecoin(account, USDT_address[hre.network.name], amount);
}

export async function mintUSDC(account: SignerWithAddress, amount: number) {
  mintStablecoin(account, USDC_address[hre.network.name], amount);
}

export async function approveUSDT(account: SignerWithAddress, spender: string, amount: number) {
  approveStablecoin(account, USDT_address[hre.network.name], spender, amount);
}

export async function approveUSDC(account: SignerWithAddress, spender: string, amount: number) {
  approveStablecoin(account, USDC_address[hre.network.name], spender, amount);
}