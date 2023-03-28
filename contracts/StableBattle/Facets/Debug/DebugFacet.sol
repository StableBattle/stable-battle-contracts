// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Pool, Coin, ClanRole } from "../../Meta/DataStructures.sol";

import { ERC1155MetadataInternal } from "@solidstate/contracts/token/ERC1155/metadata/ERC1155MetadataInternal.sol";
import { MetaStorage } from "../../Meta/MetaStorage.sol";
import { KnightStorage } from "../Knight/KnightStorage.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";
import { AccessControlModifiers } from "../AccessControl/AccessControlModifiers.sol";

import { IDebug } from "../Debug/IDebug.sol";

contract DebugFacet is IDebug, ERC1155MetadataInternal, AccessControlModifiers {
  function debugSetBaseURI(string memory baseURI) external ifCallerIsAdmin {
    _setBaseURI(baseURI);
  }

  function debugSetTokenURI(uint256 tokenId, string memory tokenURI) external ifCallerIsAdmin {
    _setTokenURI(tokenId, tokenURI);
  }

  function debugEnablePoolCoinMinting(Pool pool, Coin coin) external ifCallerIsAdmin {
    MetaStorage.state().compatible[pool][coin] = true;
  }

  function debugDisablePoolCoinMinting(Pool pool, Coin coin) external ifCallerIsAdmin {
    MetaStorage.state().compatible[pool][coin] = true;
  }

  function debugSetCoinAddress(Coin coin, address newAddress) external ifCallerIsAdmin {
    MetaStorage.state().coin[coin] = newAddress;
  }

  function debugSetACoinAddress(Coin coin, address newAddress) external ifCallerIsAdmin {
    MetaStorage.state().acoin[coin] = newAddress;
  }

  function debugSetKnightPrice(Coin coin, uint256 newPrice) external ifCallerIsAdmin {
    KnightStorage.state().knightPrice[coin] = newPrice;
  }

  function debugSetLevelThresholds(uint[] memory newThresholds) external ifCallerIsAdmin {
    ClanStorage.state().levelThresholds = newThresholds;
  }

  function debugSetWithdrawalCooldown(uint256 clanId, address user, uint newCooldownEnd) external {
    ClanStorage.state().withdrawalCooldown[clanId][user] = newCooldownEnd;
  }
}