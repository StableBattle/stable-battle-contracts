import { BigNumber } from "ethers";
import hre, { ethers } from "hardhat";
import { SBD as SBD_address, SBT as BEER_address } from "../config/goerli/main-contracts";
import { USDT as UDST_address } from "../config/sb-init-addresses";

//Mint 30 knights
//Create 3 clans with levels of 0, 1, 3
//Join knights in clans 5 in 0, 10 in 1, 15 in 3

export default async function populateClans() {
  const knights = 32;
  const clans = 3;
  await mintAndApproveUSDT(knights * 1000);
  const knightIds = await bulkMintKnights(knights);
  const clanIds = await createClans(clans, knightIds);
  await stakeInClan(50000, clanIds[1]);
  await stakeInClan(250000, clanIds[2]);
  await bulkJoinClan(clanIds[0], knightIds.slice(clans, clans + 4));
  //1 Admins, 2 Mods
  await assignClanRole(clanIds[0], knightIds[clans + 0], 3);
  await assignClanRole(clanIds[0], knightIds[clans + 1], 2);
  await assignClanRole(clanIds[0], knightIds[clans + 2], 2);
  await bulkJoinClan(clanIds[1], knightIds.slice(clans + 5, clans + 14));
  //3 Admins, 4 Mods
  await assignClanRole(clanIds[1], knightIds[clans + 5], 3);
  await assignClanRole(clanIds[1], knightIds[clans + 6], 3);
  await assignClanRole(clanIds[1], knightIds[clans + 7], 3);
  await assignClanRole(clanIds[1], knightIds[clans + 8], 2);
  await assignClanRole(clanIds[1], knightIds[clans + 9], 2);
  await assignClanRole(clanIds[1], knightIds[clans + 10], 2);
  await assignClanRole(clanIds[1], knightIds[clans + 11], 2);
  await bulkJoinClan(clanIds[2], knightIds.slice(clans + 15, clans+25));
  //2 Admins, 5 Mods
  await assignClanRole(clanIds[2], knightIds[clans + 15], 3);
  await assignClanRole(clanIds[2], knightIds[clans + 16], 3);
  await assignClanRole(clanIds[2], knightIds[clans + 17], 2);
  await assignClanRole(clanIds[2], knightIds[clans + 18], 2);
  await assignClanRole(clanIds[2], knightIds[clans + 19], 2);
  await assignClanRole(clanIds[2], knightIds[clans + 20], 2);
  await assignClanRole(clanIds[2], knightIds[clans + 21], 2);

  const SBD = await hre.ethers.getContractAt("StableBattleDummy", SBD_address);
  let tx = await SBD.leaveClan(knightIds[clans + 22], clanIds[2]); await tx.wait();
  console.log(`Knight ${knightIds[clans + 22]} left clan ${clanIds[2]}`);
  tx = await SBD.kickFromClan(knightIds[clans + 23], clanIds[2], knightIds[2]); await tx.wait();
  console.log(`Knight ${knightIds[clans + 23]} kicked from clan ${clanIds[2]} by ${knightIds[2]}`);
  tx = await SBD.joinClan(knightIds[clans + 26], clanIds[2]); await tx.wait();
  console.log(`Join request from ${knightIds[clans + 26]} into clan ${clanIds[2]} sent`);
  tx = await SBD.withdrawJoinClan(knightIds[clans + 26], clanIds[2]); await tx.wait();
  console.log(`Join request from ${knightIds[clans + 26]} into clan ${clanIds[2]} withdrawn`);
  tx = await SBD.joinClan(knightIds[clans + 26], clanIds[2]); await tx.wait();
  console.log(`Join request from ${knightIds[clans + 26]} into clan ${clanIds[2]} sent`);
  tx = await SBD.dismissJoinClan(knightIds[clans + 26], clanIds[2], knightIds[2]); await tx.wait();
  console.log(`Join request from ${knightIds[clans + 26]} into clan ${clanIds[2]} dismissed by ${knightIds[2]}`);
  tx = await SBD.joinClan(knightIds[clans + 27], clanIds[2]); await tx.wait();
  console.log(`Join request from ${knightIds[clans + 27]} into clan ${clanIds[2]} sent`);
  tx = await SBD.joinClan(knightIds[clans + 28], clanIds[2]); await tx.wait();
  console.log(`Join request from ${knightIds[clans + 28]} into clan ${clanIds[2]} sent`);
  const BEER = await hre.ethers.getContractAt("ISBT", BEER_address);
  const BEER_decimals = await BEER.decimals();
  tx = await BEER.withdraw(clanIds[2], (BigNumber.from(10).pow(BEER_decimals)).mul(100000)); await tx.wait();
  console.log(`Withdrawn ${100000} BEER tokens from ${clanIds[2]}`);
}

async function mintAndApproveUSDT(amount: number) {
  const user = (await ethers.getSigners())[0].address;
  const USDT = await hre.ethers.getContractAt("IERC20Mintable", UDST_address.goerli);
  const USDT_decimals = await USDT.decimals();
  const realAmount = amount * (10 ** USDT_decimals);
  const mintTx = await USDT.mint(user, realAmount);
  await mintTx.wait();
  console.log(`Minted ${amount} USDT to ${user}`);
  const approveTx = await USDT.approve(SBD_address, realAmount);
  await approveTx.wait();
  console.log(`Approved ${amount} USDT to ${SBD_address}`);
}

async function bulkMintKnights(n : number) : Promise<BigNumber[]> {
  const user = (await ethers.getSigners())[0].address;
  const SBD = await hre.ethers.getContractAt("StableBattleDummy", SBD_address);
  let knightIds: BigNumber[] = [];
  for(let i = 0; i < n; i++) {
    const mintTx = await SBD.mintKnight(2, 2, {gasLimit: 1000000});
    await mintTx.wait();
    const eventsKnightMinted = await SBD.queryFilter(SBD.filters.KnightMinted());
    const knightId = eventsKnightMinted.filter(evt => evt.args.wallet == user).slice(-1)[0].args.knightId;
    console.log(`Minted knight ${i} with id: ${knightId}`);
    knightIds.push(knightId);
  }
  return knightIds;
}

async function createClans(n: number, knightIds: BigNumber[]) : Promise<BigNumber[]> {
  const SBD = await hre.ethers.getContractAt("StableBattleDummy", SBD_address);
  let clanIds: BigNumber[] = [];
  let clanName = "💩";
  for(let i = 0; i < n; i++) {
    const createClanTx = await SBD.createClan(knightIds[i], clanName);
    await createClanTx.wait(10);
    const eventsClanCreated = await SBD.queryFilter(SBD.filters.ClanCreated());
    const clanId = eventsClanCreated.filter(evt => evt.args.knightId.eq(knightIds[i]))[0].args.clanId;
    console.log(`Created clan ${clanId} with knight ${knightIds[i]}`);
    clanIds.push(clanId);
    clanName += "💩";
  }
  return clanIds;
}

async function stakeInClan(n: number, clanId : BigNumber) {
  const SBD = await hre.ethers.getContractAt("StableBattleDummy", SBD_address);
  const user = (await ethers.getSigners())[0].address;
  const BEER = await hre.ethers.getContractAt("ISBT", BEER_address);
  const BEER_decimals = await BEER.decimals();
  const realStake = (BigNumber.from(10).pow(BEER_decimals)).mul(n);

  const mintTx = await BEER.adminMint(user, realStake);
  await mintTx.wait();
  console.log(`Minted ${n} BEER tokens to ${user}`);
  const stakeTx = await BEER.stake(clanId, realStake);
  await stakeTx.wait();
  console.log(`Staked ${n} BEER tokens into ${clanId}`);
  const newClanLevel = (await SBD.getClanInfo(clanId))[3];
  const clanStake = await SBD.getClanStake(clanId);
  console.log(`Clan ${clanId} leveled up to level ${newClanLevel.toString()} with total stake of ${clanStake.toString()}`)
}

async function bulkJoinClan(clanId: BigNumber, knightIds: BigNumber[]) {
  console.log("Join info: ");
  console.log(`clan ${clanId.toString()}`);
  console.log(knightIds);
  const SBD = await hre.ethers.getContractAt("StableBattleDummy", SBD_address);
  const ownerId = (await SBD.getClanInfo(clanId))[0];
  for(let i = 0; i < knightIds.length; i++) {
    const joinTx = await SBD.joinClan(knightIds[i], clanId, {gasLimit: 1000000});
    await joinTx.wait();
    console.log(`Join request from ${knightIds[i]} into clan ${clanId} sent`);
    const approveTx = await SBD.approveJoinClan(knightIds[i], clanId, ownerId);
    await approveTx.wait();
    console.log(`Join request from ${knightIds[i]} into clan ${clanId} accepted by ${ownerId}`);
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