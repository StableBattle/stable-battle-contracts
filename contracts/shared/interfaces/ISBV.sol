// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./IERC721Enumerable.sol";

interface ISBV is IERC721Enumerable {

  function adminMint(address beneficiary) external;
}