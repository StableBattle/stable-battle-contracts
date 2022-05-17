// SPDX-License-Identifier: Ulicensed

pragma solidity ^0.8.0;

interface ISBT is IERC20 {

    event Stake (address from, uint clan_id, uint amount);
    event Withdraw (address to, uint clan_id, uint amount);

    function _stake (address from, uint clan_id, uint amount);
    function _withdraw (address to, uint clan_id, uint amount);]
}
