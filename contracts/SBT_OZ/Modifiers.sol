// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

contract Modifiers {

  address[] minters;
  address[] burners;
  address owner;

  modifier onlyMinters {
    bool sentByMinter;
    for (uint i; i < minters.length; i++) {
      if (msg.sender == minters[i]) {
        sentByMinter = true;
        break;
      }
    }
    require (sentByMinter, "Only adresses with minter priveleges can use this function");
    _;
  }

  modifier onlyBurners {
    bool sentByBurner;
    for (uint i; i < burners.length; i++) {
      if (msg.sender == burners[i]) {
        sentByBurner = true;
        break;
      }
    }
    require (sentByBurner, "Only adresses with burner priveleges can use this function");
    _;
  }

  modifier onlyOwner {
    require (owner == msg.sender, "Only owner can access this function");
    _;
  }

  constructor (address[] memory _minters, address[] memory _burners) {
    minters = _minters;
    burners = _burners;
    owner = msg.sender;
  }
}