import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import populateClans from "../scripts/onChainTest/populateClans";
import SBFixture, { SBFixtureInterface } from "./libraries/SBFixture";


describe('populateScriptTest', async function () {
  let SB : SBFixtureInterface;

  before(async function () {
    SB = await loadFixture(SBFixture);
  });

  it('Should run populate script without errors', async () => {
    await populateClans();
  });
})
