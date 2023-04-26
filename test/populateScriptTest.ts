//import populateClans from "../scripts/onChainTest/populateClans";
import deployPopulateEvents from "../scripts/deployPopulateEvents";
import { IERC20Mintable, IStableBattle, PopulateEvents } from "../typechain-types";
import deployStableBattle from "../scripts/deployStableBattle";
import { SBD } from "../scripts/config/hardhat/main-contracts";
import hre from "hardhat";
import { USDT as UDST_address } from "../scripts/config/sb-init-addresses";

describe("populateScriptTest", async function () {
  let StableBattle : IStableBattle;
  let populateEvents : PopulateEvents;
  let USDT : IERC20Mintable;
  const wallet = new hre.ethers.Wallet(process.env.PRIVATE_KEY as string, hre.ethers.provider);

  before(async function () {
    await deployStableBattle();
    StableBattle = await hre.ethers.getContractAt("IStableBattle", SBD);
    USDT = await hre.ethers.getContractAt("IERC20Mintable", UDST_address[hre.network.name]);
  });

  it("Should deploy populate script without errors", async () => {
    const popEventsAddress = await deployPopulateEvents();
    USDT.connect(wallet).approve(popEventsAddress, 1000000 * 10 ** 6);
    populateEvents = await hre.ethers.getContractAt("PopulateEvents", popEventsAddress);
  });

  it("Should run populateEvents without errors", async () => {
    await populateEvents.connect(wallet).populateEvents();
  });
})
