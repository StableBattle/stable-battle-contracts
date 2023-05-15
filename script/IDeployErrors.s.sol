// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

interface IDeployErrors {
  error NoSelectorsInCut(uint256 cutIndex);
  error ZeroAddressInCut(uint256 cutIndex);
  error InvalidActionInCut(uint256 cutIndex);
}