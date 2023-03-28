// SPDX-License-Identifier: Unlicensed

import { IAToken } from "@aave/core-v3/contracts/interfaces/IAToken.sol";
import { ISolidStateERC20 } from "@solidstate/contracts/token/ERC20/ISolidStateERC20.sol";
import { SolidStateERC20 } from "@solidstate/contracts/token/ERC20/SolidStateERC20.sol";
import { IERC20 } from "@solidstate/contracts/token/ERC20/IERC20.sol";
import { ERC20Base } from "@solidstate/contracts/token/ERC20/base/ERC20Base.sol";
import { ERC20MetadataStorage } from "@solidstate/contracts/token/ERC20/metadata/ERC20MetadataStorage.sol";

pragma solidity ^0.8.0;

contract USDTMock is SolidStateERC20 {
  using ERC20MetadataStorage for ERC20MetadataStorage.Layout;
  
  constructor() {
    ERC20MetadataStorage.Layout storage l = ERC20MetadataStorage.layout();

    l.setName("USDT");
    l.setSymbol("USDT");
    l.setDecimals(6);
  }

  function mint(address to, uint256 amount) external {
    _mint(to, amount);
  }

  function burn(address from, uint256 amount) external {
    _burn(from, amount);
  }
}

contract AUSDTMock is SolidStateERC20 {
  using ERC20MetadataStorage for ERC20MetadataStorage.Layout;
  
  constructor() {
    ERC20MetadataStorage.Layout storage l = ERC20MetadataStorage.layout();

    l.setName("AUSDT");
    l.setSymbol("AUSDT");
    l.setDecimals(6);
  }

  function mint(address to, uint256 amount) external {
    _mint(to, amount);
  }

  function burn(address from, uint256 amount) external {
    _burn(from, amount);
  }

  function balanceOf(address account) public view override(ERC20Base, IERC20) returns (uint256) {
    return super.balanceOf(account) + 1000 * 10 ** 6;
  }
}

contract AAVEMock {
  AUSDTMock immutable AUSDT;
  ISolidStateERC20 immutable USDT;

  constructor(address AUSDTMockAddress, address USDTMockAddress) {
    AUSDT = AUSDTMock(AUSDTMockAddress);
    USDT = ISolidStateERC20(USDTMockAddress);
  }

  function supply(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external {
    require(USDT.allowance(msg.sender, address(this)) >= amount, "Not enough allowance");
    USDT.transferFrom(msg.sender, address(this), amount);
    AUSDT.mint(onBehalfOf, amount);
  }

  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256) {
    AUSDT.burn(msg.sender, amount);
    USDT.transfer(to, amount);
    return amount;
  }
}