// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { Diamond } from "../Diamond/Diamond.sol";
import { Create2 } from "openzeppelin-contracts/utils/Create2.sol";

contract Create2Deployer {
  function deployDiamond(uint256 salt) external {
    Create2.deploy(0, bytes32(salt), type(Diamond).creationCode);
  }

  function getBytecode(uint _salt) external view returns(address) {
    bytes32 hash = keccak256(
      abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(type(Diamond).creationCode))
    );
    return address(uint160(uint(hash)));
  }
}