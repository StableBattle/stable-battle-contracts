// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { BEERSetupLib } from "../../../BEER/BEERSetupLib.sol";

library ClanSetupLib {
  function clanStakeLevelThresholds() internal pure returns(uint256[] memory) {
    uint256[] memory thresholds = new uint256[](6);
    thresholds[0] = 0;
    thresholds[1] = 40000  * (10 ** BEERSetupLib.decimals);
    thresholds[2] = 110000 * (10 ** BEERSetupLib.decimals);
    thresholds[3] = 230000 * (10 ** BEERSetupLib.decimals);
    thresholds[4] = 430000 * (10 ** BEERSetupLib.decimals);
    thresholds[5] = 760000 * (10 ** BEERSetupLib.decimals);
    return thresholds;
  }
  function maxMembersPerLevel() internal pure returns(uint256[] memory) {
    uint256[] memory maxMembers = new uint256[](6);
    maxMembers[0] = 10;
    maxMembers[1] = 20;
    maxMembers[2] = 22;
    maxMembers[3] = 24;
    maxMembers[4] = 26;
    maxMembers[5] = 28;
    maxMembers[6] = 30;
    return maxMembers;
  }
  uint256 internal constant clanActivityCooldownConst = 2 days;
  uint256 internal constant clanKickCoolDownConst = 1 hours;
  uint256 internal constant clanStakeWithdrawCooldownConst = 2 weeks;
}