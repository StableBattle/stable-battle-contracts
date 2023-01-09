// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { SolidStateERC20 } from "@solidstate/contracts/token/ERC20/SolidStateERC20.sol";
import { ISBT } from "./ISBT.sol";
import { SBTGetters } from "./SBTGetters.sol";
import { OwnableInternal } from "@solidstate/contracts/access/ownable/OwnableInternal.sol";

contract SBTImplementation is 
  ISBT, 
  SolidStateERC20, 
  SBTGetters,
  OwnableInternal
{
  function adminMint(address account, uint256 amount)
    external
  //onlyOwner
  {
    _mint(account, amount);
  }

  function adminBurn(address account, uint256 amount)
    external
  //onlyOwner
  {
    _burn(account, amount);
  }

  function treasuryMint(address[] memory accounts, uint256[] memory amounts)
    external
  //onlySBD
  {
    require(accounts.length == amounts.length,
      "SBT: arrays are of different sizes");
    for(uint i; i < accounts.length; i++) {
      _mint (accounts[i], amounts[i]);
    }
  }

  function stake(uint clanId, uint256 amount) external {
    _transfer(msg.sender, address(Clan()), amount);
    Clan().onStake(msg.sender, clanId, amount);
    emit Stake(msg.sender, clanId, amount);
  }

  function withdraw(uint clanId, uint256 amount) external {
    require(Clan().getStakeOf(msg.sender, clanId) >= amount,
      "SBT: withdrawal amount exceeds stake");
    _transfer(address(Clan()), msg.sender, amount);
    Clan().onWithdraw(msg.sender, clanId, amount);
    emit Withdraw(msg.sender, clanId, amount);
  }
}