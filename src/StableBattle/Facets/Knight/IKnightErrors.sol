// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IKnightErrors {
  error KnightFacet_InsufficientFunds(uint256 avalible, uint256 required);
  error KnightModifiers_WrongKnightId(uint256 wrongId);
  error KnightModifiers_KnightNotInAnyClan(uint256 knightId);
  error KnightModifiers_KnightNotInClan(uint256 knightId, uint256 wrongClanId, uint256 correctClanId);
  error KnightModifiers_KnightInSomeClan(uint256 knightId, uint256 clanId);
}
