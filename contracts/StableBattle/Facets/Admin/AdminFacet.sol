// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Pool, Coin } from "../../Meta/DataStructures.sol";

import { ERC1155MetadataInternal } from "@solidstate/contracts/token/ERC1155/metadata/ERC1155MetadataInternal.sol";
import { MetaStorage } from "../../Meta/MetaStorage.sol";
import { KnightStorage } from "../Knight/KnightStorage.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";

contract AdminFacet is ERC1155MetadataInternal {
  function debugSetBaseURI(string memory baseURI) external {
    _setBaseURI(baseURI);
  }

  function debugSetTokenURI(uint256 tokenId, string memory tokenURI) external {
    _setTokenURI(tokenId, tokenURI);
  }

  function debugEnablePoolCoinMinting(Pool pool, Coin coin) external {
    MetaStorage.state().compatible[pool][coin] = true;
  }

  function debugDisablePoolCoinMinting(Pool pool, Coin coin) external {
    MetaStorage.state().compatible[pool][coin] = true;
  }

  function debugSetCoinAddress(Coin coin, address newAddress) external {
    MetaStorage.state().coin[coin] = newAddress;
  }

  function debugSetACoinAddress(Coin coin, address newAddress) external {
    MetaStorage.state().acoin[coin] = newAddress;
  }

  function debugSetKnightPrice(Coin coin, uint256 newPrice) external {
    KnightStorage.state().knightPrice[coin] = newPrice;
  }

  function debugSetMaxClanMembers(uint newMaxClanMembers) external {
    ClanStorage.state().MAX_CLAN_MEMBERS = newMaxClanMembers;
  }

  function debugSetLevelThresholds(uint[] memory newThresholds) external {
    ClanStorage.state().levelThresholds = newThresholds;
  }
}