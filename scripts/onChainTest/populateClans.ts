import { BigNumber } from "ethers";
import hre, { ethers } from "hardhat";
import { SBD as SBD_address, SBT as SBT_address } from "../config/goerli/main-contracts";
import { USDT as UDST_address } from "../config/sb-init-addresses";

//Mint 30 knights
//Create 3 clans with levels of 0, 1, 3
//Join knights in clans 5 in 0, 10 in 1, 15 in 3

export default async function populateClans() {
  const knights = 30;
  const clans = 3;
  await mintAndApproveUSDT(knights * 1000);
  const knightIds = await bulkMintKnights(knights);
  const clanIds = await createClans(clans, knightIds);
  await stakeInClan(100, clanIds[1]);
  await stakeInClan(300, clanIds[2]);
  await bulkJoinClan(clanIds[0], knightIds.slice(clans, clans + 4));
  //1 Admins, 2 Mods
  await assignClanRole(clanIds[0], knightIds[clans + 0], 2);
  await assignClanRole(clanIds[0], knightIds[clans + 1], 1);
  await assignClanRole(clanIds[0], knightIds[clans + 2], 1);
  await bulkJoinClan(clanIds[1], knightIds.slice(clans + 5, clans + 14));
  //3 Admins, 4 Mods
  await assignClanRole(clanIds[1], knightIds[clans + 5], 2);
  await assignClanRole(clanIds[1], knightIds[clans + 6], 2);
  await assignClanRole(clanIds[1], knightIds[clans + 7], 2);
  await assignClanRole(clanIds[1], knightIds[clans + 8], 1);
  await assignClanRole(clanIds[1], knightIds[clans + 9], 1);
  await assignClanRole(clanIds[1], knightIds[clans + 10], 1);
  await assignClanRole(clanIds[1], knightIds[clans + 11], 1);
  await bulkJoinClan(clanIds[2], knightIds.slice(clans + 15));
  //2 Admins, 5 Mods
  await assignClanRole(clanIds[2], knightIds[clans + 15], 2);
  await assignClanRole(clanIds[2], knightIds[clans + 16], 2);
  await assignClanRole(clanIds[2], knightIds[clans + 17], 1);
  await assignClanRole(clanIds[2], knightIds[clans + 18], 1);
  await assignClanRole(clanIds[2], knightIds[clans + 19], 1);
  await assignClanRole(clanIds[2], knightIds[clans + 20], 1);
  await assignClanRole(clanIds[2], knightIds[clans + 21], 1);
}

async function mintAndApproveUSDT(amount: number) {
  const user = (await ethers.getSigners())[0].address;
  const USDT = await hre.ethers.getContractAt("IERC20Mintable", UDST_address.goerli);
  const USDT_decimals = await USDT.decimals();
  const realAmount = amount * (10 ** USDT_decimals);
  const mintTx = await USDT.mint(user, realAmount);
  await mintTx.wait();
  console.log(`Minted ${amount} USDT to ${user}: ${mintTx.hash}`);
  const approveTx = await USDT.approve(SBD_address, realAmount);
  await approveTx.wait();
  console.log(`Approved ${amount} USDT to ${SBD_address}: ${approveTx.hash}`);
}

async function bulkMintKnights(n : number) : Promise<BigNumber[]> {
  const user = (await ethers.getSigners())[0].address;
  const SBD = await hre.ethers.getContractAt("StableBattleDummy", SBD_address);
  let knightIds: BigNumber[] = [];
  for(let i = 0; i < n; i++) {
    const mintTx = await SBD.mintKnight(2, 2);
    await mintTx.wait();
    const eventsKnightMinted = await SBD.queryFilter(SBD.filters.KnightMinted());
    const knightId = eventsKnightMinted.filter(evt => evt.args.wallet == user).slice(-1)[0].args.knightId;
    console.log(`Minted knight ${knightId}: ${mintTx.hash}`);
    knightIds.push(knightId);
  }
  return knightIds;
}

async function createClans(n: number, knightIds: BigNumber[]) : Promise<BigNumber[]> {
  const SBD = await hre.ethers.getContractAt("StableBattleDummy", SBD_address);
  let clanIds: BigNumber[] = [];
  for(let i = 0; i < n; i++) {
    const createClanTx = await SBD.createClan(knightIds[i]);
    await createClanTx.wait(10);
    const eventsClanCreated = await SBD.queryFilter(SBD.filters.ClanCreated());
    const clanId = eventsClanCreated.filter(evt => evt.args.knightId.eq(knightIds[i]))[0].args.clanId;
    console.log(`Created clan ${clanId} with knight ${knightIds[i]}: ${createClanTx.hash}`);
    clanIds.push(clanId);
  }
  return clanIds;
}

async function stakeInClan(n: number, clanId : BigNumber) {
  const SBD = await hre.ethers.getContractAt("StableBattleDummy", SBD_address);
  const user = (await ethers.getSigners())[0].address;
  const SBT = await hre.ethers.getContractAt("ISBT", SBT_address);

  const mintTx = await SBT.adminMint(user, n);
  await mintTx.wait();
  console.log(`Minted ${n} BEER tokens to ${user}: ${mintTx.hash}`);
  const stakeTx = await SBT.stake(clanId, n);
  await stakeTx.wait();
  console.log(`Staked ${n} BEER tokens into ${clanId}: ${stakeTx.hash}`);
  const newClanLevel = (await SBD.getClanInfo(clanId))[3];
  const newMaxClanMembers = await SBD.getClanLevelThreshold(newClanLevel);
  console.log(`Clan ${clanId} leveled up to level ${newClanLevel.toString()} with total stake of ${newMaxClanMembers.toString()} members`)
}

async function bulkJoinClan(clanId: BigNumber, knightIds: BigNumber[]) {
  console.log("Join info: ");
  console.log(`clan ${clanId.toString()}`);
  console.log(knightIds);
  const SBD = await hre.ethers.getContractAt("StableBattleDummy", SBD_address);
  const ownerId = (await SBD.getClanInfo(clanId))[0];
  for(let i = 0; i < knightIds.length; i++) {
    const joinTx = await SBD.join(knightIds[i], clanId);
    await joinTx.wait();
    console.log(`Join request from ${knightIds[i]} into clan ${clanId} sent: ${joinTx.hash}`);
    const approveTx = await SBD.approveJoinClan(knightIds[i], clanId, ownerId);
    await approveTx.wait();
    console.log(`Join request from ${knightIds[i]} into clan ${clanId} accepted by ${ownerId}: ${approveTx.hash}`);
  }
}

async function assignClanRole(clanId: BigNumber, knightId: BigNumber, newRole: number) {
  const SBD = await hre.ethers.getContractAt("StableBattleDummy", SBD_address);
  const ownerId = (await SBD.getClanInfo(clanId))[0];
  const setClanRoleTx = await SBD.setClanRole(clanId, knightId, newRole, ownerId);
  await setClanRoleTx.wait();
  console.log(`Assigned ${knightId} role ${newRole == 0 ? "NONE" : newRole == 1 ? "MOD" : newRole == 2 ? "ADMIN" : "OWNER"} in clan ${clanId}`);
}

populateClans().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});