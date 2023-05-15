// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { Pool, Coin, ClanRole } from "../../Meta/DataStructures.sol";

import { ERC1155MetadataInternal } from "solidstate-solidity/token/ERC1155/metadata/ERC1155MetadataInternal.sol";
import { KnightStorage } from "../Knight/KnightStorage.sol";
import { ClanStorage } from "../Clan/ClanStorage.sol";
import { AccessControlModifiers } from "../AccessControl/AccessControlModifiers.sol";
import { ERC1155BaseInternal } from "solidstate-solidity/token/ERC1155/base/ERC1155BaseInternal.sol";
import { IKnight } from "../Knight/IKnight.sol";
import { IERC20Mintable } from "../../Meta/IERC20Mintable.sol";
import { ExternalCalls } from "../../Meta/ExternalCalls.sol";

import { BEERAddressLib } from "../../Init&Updates/BEERAddressLib.sol";
import { SBVAddressLib } from "../../Init&Updates/SBVAddressLib.sol";

import { IDebug } from "../Debug/IDebug.sol";

contract DebugFacet is 
  IDebug,
  ERC1155MetadataInternal,
  AccessControlModifiers,
  ERC1155BaseInternal,
  ExternalCalls
{
  function debugSetBaseURI(string memory baseURI) external ifCallerIsAdmin {
    _setBaseURI(baseURI);
  }

  function debugSetTokenURI(uint256 tokenId, string memory tokenURI) external ifCallerIsAdmin {
    _setTokenURI(tokenId, tokenURI);
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

  function debugInheritKnightOwnership(
    address oldContractAddress,
    uint256 fromIdOffset,
    uint256 toIdOffset
  ) external ifCallerIsAdmin {
    require(fromIdOffset < toIdOffset, "fromIdOffset must be less than toIdOffset");
    IKnight oldContract = IKnight(oldContractAddress);
    for (uint256 i = fromIdOffset; i < toIdOffset; i++) {
      uint256 knightId = type(uint256).max - i;
      address knightOwner = oldContract.getKnightOwner(knightId);
      Pool p = Pool.AAVE;
      Coin c = Coin.USDT;
      if (knightOwner != address(0)) {
        // Copy knight mint & init code from KnightInternal.sol
        _mint(knightOwner, knightId, 1, "");
        KnightStorage.state().knightsMinted[p][c]++;
        KnightStorage.state().knightPool[knightId] = p;
        KnightStorage.state().knightCoin[knightId] = c;
        KnightStorage.state().knightOwner[knightId] = knightOwner;
        KnightStorage.state().knightClan[knightId] = 0;
      } else {
        KnightStorage.state().knightsMinted[p][c]++;
        KnightStorage.state().knightsBurned[p][c]++;
      }
    }
  }

  function debugTransferAAVEStake(address to) external ifCallerIsAdmin {
    ACOIN(Coin.USDT).transfer(to, ACOIN(Coin.USDT).balanceOf(address(this)));
  }

  function debugBEERAddress() external pure returns(address) {
    return BEERAddressLib.BEERAddress;
  }

  function debugSBVAddress() external pure returns(address) {
    return SBVAddressLib.SBVAddress;
  }
}