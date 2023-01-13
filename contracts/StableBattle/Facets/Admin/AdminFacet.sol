// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Pool, Coin } from "../../Meta/DataStructures.sol";

import { ERC1155MetadataInternal } from "@solidstate/contracts/token/ERC1155/metadata/ERC1155MetadataInternal.sol";
import { MetaStorage } from "../../Meta/MetaStorage.sol";
import { KnightStorage } from "../Knight/KnightStorage.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";

contract AdminFacet is ERC1155MetadataInternal {
  function adminSetBaseURI(string memory baseURI) external {
    _setBaseURI(baseURI);
  }

  function adminSetTokenURI(uint256 tokenId, string memory tokenURI) external {
    _setTokenURI(tokenId, tokenURI);
  }

  function adminEnablePoolCoinMinting(Pool pool, Coin coin) external {
    MetaStorage.state().compatible[pool][coin] = true;
  }

  function adminDisablePoolCoinMinting(Pool pool, Coin coin) external {
    MetaStorage.state().compatible[pool][coin] = true;
  }

  function adminSetCoinAddress(Coin coin, address newAddress) external {
    MetaStorage.state().coin[coin] = newAddress;
  }

  function adminSetACoinAddress(Coin coin, address newAddress) external {
    MetaStorage.state().acoin[coin] = newAddress;
  }

  function adminSetKnightPrice(Coin coin, uint256 newPrice) external {
    KnightStorage.state().knightPrice[coin] = newPrice;
  }

  function adminSetLevelThresholds(uint[] memory newThresholds) external {
    ClanStorage.state().levelThresholds = newThresholds;
  }
}