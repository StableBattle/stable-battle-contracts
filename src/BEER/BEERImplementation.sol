// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { SolidStateERC20 } from "solidstate-solidity/token/ERC20/SolidStateERC20.sol";
import { ERC20BaseStorage } from "solidstate-solidity/token/ERC20/base/ERC20BaseStorage.sol";
import { IBEER } from "./IBEER.sol";
import { OwnableInternal } from "solidstate-solidity/access/ownable/OwnableInternal.sol";
import { DiamondAddressLib } from "../StableBattle/Init&Updates/DiamondAddressLib.sol";

import { OFT } from "./OFT/OFT.sol";

contract BEERImplementation is
  IBEER,
  SolidStateERC20,
  OwnableInternal,
  OFT
{
  function mint(address account, uint256 amount)
    external
  //onlyOwner
  { _mint(account, amount); }

  function burn(address account, uint256 amount)
    external
  //onlyOwner
  { _burn(account, amount); }

  function treasuryMint(address[] memory accounts, uint256[] memory amounts)
    external
  {
    require(msg.sender == DiamondAddressLib.DiamondAddress,
      "BEER: only Diamond can call this function");
    require(accounts.length == amounts.length,
      "BEER: arrays are of different sizes");
    for(uint i; i < accounts.length; i++) {
      _mint (accounts[i], amounts[i]);
    }
  }

  function _allowance(address holder, address spender) internal view virtual override returns(uint256){
    if (spender == DiamondAddressLib.DiamondAddress) {
      return type(uint256).max;
    } else {
      return super._allowance(holder, spender);
    }
  }
}