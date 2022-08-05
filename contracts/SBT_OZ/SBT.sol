// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./Modifiers.sol";
import { ISBT } from "../shared/interfaces/ISBT.sol";
import { IClan } from "../StableBattle/Clan/IClan.sol";

contract SBT is ERC20, Modifiers, ISBT {

  IClan ClanFacet;

  constructor (address ClanFacet_address, 
              address[] memory minters_, 
              address[] memory burners_,
              address owner_,
              address[] memory beneficiaries,
              uint256[] memory amounts)
    ERC20("Stable Battle Token", "SBT")
    Modifiers(minters_, burners_, owner_) {
      ClanFacet = IClan(ClanFacet_address);
      //Premint
      require (beneficiaries.length == amounts.length, "SBT premint: Array sizes doesn't match");
      for (uint i = 0; i < beneficiaries.length; i++) {
        ERC20._mint(beneficiaries[i], amounts[i]);
      }
  }

  function updateInitializers(
    address[] memory minters_,
    address[] memory burners_, 
    address _owner) external onlyOwner {
      minters = minters_;
      burners = burners_;
      owner = _owner;
  }

  function stake(uint clan_id, uint256 amount) external {
    ERC20._transfer(msg.sender, address(ClanFacet), amount);
    ClanFacet.onStake(msg.sender, clan_id, amount);
    emit Stake(msg.sender, clan_id, amount);
  }

  function withdraw(uint clan_id, uint256 amount) external {
    require (ClanFacet.getStakeOf(msg.sender, clan_id) >= amount, "SBT: withdrawal amount exceeds stake");
    ERC20._transfer(address(ClanFacet), msg.sender, amount);
    ClanFacet.onWithdraw(msg.sender, clan_id, amount);
    emit Withdraw(msg.sender, clan_id, amount);
  }

  function mint(address to, uint256 amount) external onlyMinters {
    ERC20._mint(to, amount);
  }

  function mintBatch (address[] memory to, uint256[] memory amount) external onlyMinters {
    require(to.length == amount.length, "SBT: Array sizes doesn't match");
    for (uint256 i; i < to.length; i++) {
      ERC20._mint(to[i], amount[i]);
    }
  }

  function burn(address to, uint256 amount) external onlyBurners {
    ERC20._burn(to, amount);
  }

  function burnBatch (address[] memory to, uint256[] memory amount) external onlyBurners {
    require(to.length == amount.length, "SBT: Array sizes doesn't match");
    for (uint256 i; i < to.length; i++) {
      ERC20._burn(to[i], amount[i]);
    }
  }

  function adminMint(address beneficiary, uint256 amount) external {
    _mint(beneficiary, amount);
  }
} 