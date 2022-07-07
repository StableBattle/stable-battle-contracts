// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { gearSlot } from "../../StableBattle/storage/GearStorage.sol";

interface IForge {
  function mintGear(uint id, uint amount, address to) external;

  function mintGear(uint id, uint amount) external;

  function burnGear(uint id, uint amount, address from) external;

  function burnGear(uint id, uint amount) external;

  event GearMinted(uint256 id, uint256 amount, address to);
  event GearBurned(uint256 id, uint256 amount, address from);
}