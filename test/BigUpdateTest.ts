import { ethers } from "hardhat";
import updateStableBattle2 from "../scripts/updateStableBattle2";

describe('BigUpdateTest', async function () {

  before(async function () {
    const StableBattle = await ethers.getContractAt(
      "IStableBattle",
      "0x6551C3EC64aA6E97097467Bd0fD69B4D49c155Be"
    );
  })

  describe('Update contract', async function () {
    it('Should update StableBattle without errors', async () => {
      await updateStableBattle2();
    })
  })
})
