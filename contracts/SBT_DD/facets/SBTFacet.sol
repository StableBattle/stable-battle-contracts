// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import "./ERC20.sol";
import "../../shared/interfaces/ISBT.sol";

contract SBTFacet is ERC20, ISBT {

  function stake(uint clan_id, uint256 amount) external {
    ERC20._transfer(msg.sender, address(s.ClanFacet), amount);
    s.ClanFacet.onStake(msg.sender, clan_id, amount);
    emit Stake(msg.sender, clan_id, amount);
  }

  function withdraw(uint clan_id, uint256 amount) external {
    require(s.ClanFacet.stakeOf(msg.sender, clan_id) >= amount, "SBT: withdrawal amount exceeds stake");
    ERC20._transfer(address(s.ClanFacet), msg.sender, amount);
    s.ClanFacet.onWithdraw(msg.sender, clan_id, amount);
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

  modifier onlyMinters() {
    bool sentByMinter;
    for (uint i; i < s.minters.length; i++) {
      if (msg.sender == s.minters[i]) {
        sentByMinter = true;
        break;
      }
    }
    require(sentByMinter, "SBT: Only adresses with minter priveleges can use this function");
    _;
  }

  modifier onlyBurners() {
    bool sentByBurner;
    for (uint i; i < s.burners.length; i++) {
      if (msg.sender == s.burners[i]) {
        sentByBurner = true;
        break;
      }
    }
    require(sentByBurner, "SBT: Only adresses with burner priveleges can use this function");
    _;
  }
}