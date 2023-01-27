const testnet: string = process.env.TESTNET_NAME || "";

interface AddressPerNetwork {
  readonly [index: string]: string
}

export const AAVE : AddressPerNetwork = {
  goerli: "0x368EedF3f56ad10b9bC57eed4Dac65B26Bb667f6",
  mumbai: "0x6C9fB0D5bD9429eb9Cd96B85B81d872281771E6B",
  get hardhat(): string {
    return this[testnet];
  }
}

export const USDT : AddressPerNetwork = {
  goerli: "0xC2C527C0CACF457746Bd31B2a698Fe89de2b6d49",
  mumbai: "0x21C561e551638401b937b03fE5a0a0652B99B7DD",
  get hardhat(): string {
    return this[testnet];
  }
}

export const USDC : AddressPerNetwork = {
  goerli: "0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43",
  mumbai: "0x9aa7fEc87CA69695Dd1f879567CcF49F3ba417E2",
  get hardhat(): string {
    return this[testnet];
  }
}

export const EURS : AddressPerNetwork = {
  goerli: "0xc31E63CB07209DFD2c7Edb3FB385331be2a17209",
  mumbai: "0x302567472401C7c7B50ee7eb3418c375D8E3F728",
  get hardhat(): string {
    return this[testnet];
  }
}

export const AUSDT : AddressPerNetwork = {
  goerli: "0x73258E6fb96ecAc8a979826d503B45803a382d68",
  mumbai: "0x6Ca4abE253bd510fCA862b5aBc51211C1E1E8925",
  get hardhat(): string {
    return this[testnet];
  }
}
export const AUSDC : AddressPerNetwork = {
  goerli: "0x1Ee669290939f8a8864497Af3BC83728715265FF",
  mumbai: "0xCdc2854e97798AfDC74BC420BD5060e022D14607",
  get hardhat(): string {
    return this[testnet];
  }
}
export const AEURS : AddressPerNetwork = {
  goerli: "0xaA63E0C86b531E2eDFE9F91F6436dF20C301963D",
  mumbai: "0xf6AeDD279Aae7361e70030515f56c22A16d81433",
  get hardhat(): string {
    return this[testnet];
  }
}