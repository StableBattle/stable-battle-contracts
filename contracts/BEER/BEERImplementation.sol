// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { SolidStateERC20 } from "@solidstate/contracts/token/ERC20/SolidStateERC20.sol";
import { ERC20BaseStorage } from "@solidstate/contracts/token/ERC20/base/ERC20BaseStorage.sol";
import { IBEER } from "./IBEER.sol";
import { BEERGetters } from "./BEERGetters.sol";
import { OwnableInternal } from "@solidstate/contracts/access/ownable/OwnableInternal.sol";
import { DiamondAddressLib } from "../StableBattle/Init&Updates/DiamondAddressLib.sol";

contract BEERImplementation is 
  IBEER,
  SolidStateERC20,
  BEERGetters,
  OwnableInternal
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
  //onlySBD
  {
    require(accounts.length == amounts.length,
      "BEER: arrays are of different sizes");
    for(uint i; i < accounts.length; i++) {
      _mint (accounts[i], amounts[i]);
    }
  }

  function _allowance(address holder, address spender) internal view virtual override returns(uint256){
    if (spender == SBD()) {
      return type(uint256).max;
    } else {
      return ERC20BaseStorage.layout().allowances[holder][spender];
    }
  }

  function diamondAddress() external pure returns(address) {
    return DiamondAddressLib.DiamondAddress;
  }
}