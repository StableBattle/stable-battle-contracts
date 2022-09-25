import exp from "constants"
import { IERC20Mintable } from "../../typechain-types"

export interface CoinInterface {
  readonly [index: string]: IERC20Mintable
}

export const COIN = {
  NONE : 0,
  TEST : 1,
  USDT : 2,
  USDC : 3,
  EURS : 4
}

export const POOL = {
  NONE : 0,
  TEST : 1,
  AAVE : 2
}

export const gearSlot = {
  NONE    : 0,
  WEAPON  : 1,
  SHIELD  : 2,
  HELMET  : 3,
  ARMOR   : 4,
  PANTS   : 5,
  SLEEVES : 6,
  GLOVES  : 7,
  BOOTS   : 8,
  JEWELRY : 9,
  CLOAK   : 10
}