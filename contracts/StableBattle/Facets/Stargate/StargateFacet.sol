// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { ExternalCalls } from "../../Meta/ExternalCalls.sol";
import { Coin } from "../../Meta/DataStructures.sol";
import { IERC20 } from "@solidstate/contracts/token/ERC20/IERC20.sol";

interface IStargatePoolShort {
  function deposit(uint256 _pid, uint256 _amount) external;
  function withdraw(uint256 _pid, uint256 _amount) external;
}

interface IStargateRouterShort {
  function addLiquidity(uint256 _poolId, uint256 _amountLD, address _to) external;
  function instantRedeemLocal(uint16 _srcPoolId, uint256 _amountLP, address _to) external returns (uint256);
}

interface IStargate {
  function stakeToStargate(Coin coin, uint256 amount) external;
  function withdrawFromStargate(Coin coin, uint256 amount) external;

  error StargateFacet_NoCorrespondingPoolId(Coin coin);
  event StargateStakeAdded(Coin coin, uint256 amount);
  event StargateStakeWithdrawn(Coin coin, uint256 amount);
}

contract StargateFacet is IStargate, ExternalCalls {
  function coinToPoolid(Coin coin) internal pure returns(uint16) {
    if(coin == Coin.USDT) {
      return 19;
    }
    revert StargateFacet_NoCorrespondingPoolId(coin);
  }

  function SCOIN(Coin coin) internal view returns(IERC20) {
    return IERC20(StargateStorage.state().stargate_coin[coin]);
  }

  function SFARM(Coin coin) internal view returns(IStargatePoolShort) {
    return IStargatePoolShort(StargateStorage.state().stargate_coin[coin]);
  }

  function Stargate() internal view returns(IStargateRouterShort) {
    return IStargateRouterShort(StargateStorage.state().stargate_address);
  }

  function stakeToStargate(Coin coin, uint256 amount) external {
    COIN(coin).approve(address(Stargate()), amount);
    Stargate().addLiquidity(coinToPoolid(coin), amount, address(this));
    SCOIN(coin).approve(address(SFARM(coin)), amount);
    SFARM(coin).deposit(0, amount);
    emit StargateStakeAdded(coin, amount);
  }

  function withdrawFromStargate(Coin coin, uint256 amount) external {
    SFARM(coin).withdraw(0, amount);
    Stargate().instantRedeemLocal(coinToPoolid(coin), amount, address(this));
    emit StargateStakeWithdrawn(coin, amount);
  }
}

library StargateStorage {
  struct State {
    address stargate_address;
    mapping (Coin => address) stargate_coin;
    mapping (Coin => address) stargate_farm;
  }

  bytes32 internal constant STORAGE_SLOT = keccak256("Stargate.integration.storage");

  function state() internal pure returns (State storage l) {
    bytes32 slot = STORAGE_SLOT;
    assembly {
      l.slot := slot
    }
  }
}