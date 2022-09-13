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
  USDT : 2
}