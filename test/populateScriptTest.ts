import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
//import populateClans from "../scripts/onChainTest/populateClans";
import deployPopulateEvents from "../scripts/deployPopulateEvents";
import SBFixture, { SBFixtureInterface } from "./libraries/SBFixture";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { PopulateEvents } from "../typechain-types";


describe("populateScriptTest", async function () {
  let SB : SBFixtureInterface;
  let accounts : SignerWithAddress[];
  let populateEvents : PopulateEvents;

  before(async function () {
    SB = await loadFixture(SBFixture);
    accounts = await ethers.getSigners();
  });

  it("Should deploy populate script without errors", async () => {
    const popEventsAddress = await deployPopulateEvents();
    populateEvents = await ethers.getContractAt("PopulateEvents", popEventsAddress);
  });

  it("Should run popualte events without errors", async () => {
    populateEvents.populateEvents();
  });
})
