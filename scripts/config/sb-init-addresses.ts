const testnet: string = process.env.TESTNET_NAME || "";

interface AddressPerNetwork {
  readonly [index: string]: string
}

export const AAVE : AddressPerNetwork = {
  goerli: "0x368EedF3f56ad10b9bC57eed4Dac65B26Bb667f6",
  mumbai: "0x0b913a76beff3887d35073b8e5530755d60f78c7",
  ethereum: "0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2",
  get hardhat(): string {
    return this[testnet];
  }
}

export const USDT : AddressPerNetwork = {
  goerli: "0xC2C527C0CACF457746Bd31B2a698Fe89de2b6d49",
  mumbai: "0xAcDe43b9E5f72a4F554D4346e69e8e7AC8F352f0",
  ethereum: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
  get hardhat(): string {
    return this[testnet];
  }
}

export const USDC : AddressPerNetwork = {
  goerli: "0xA2025B15a1757311bfD68cb14eaeFCc237AF5b43",
  mumbai: "0xe9DcE89B076BA6107Bb64EF30678efec11939234",
  ethereum: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
  get hardhat(): string {
    return this[testnet];
  }
}

export const EURS : AddressPerNetwork = {
  goerli: "0xc31E63CB07209DFD2c7Edb3FB385331be2a17209",
  mumbai: "0xF6379c02780AB48f55EE5F79dC5083C5a15583b9",
  ethereum: "0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2",
  get hardhat(): string {
    return this[testnet];
  }
}

export const AUSDT : AddressPerNetwork = {
  goerli: "0x73258E6fb96ecAc8a979826d503B45803a382d68",
  mumbai: "0xEF4aEDfD3552db80E8F5133ed5c27cebeD2fE015",
  ethereum: "0x23878914EFE38d27C4D67Ab83ed1b93A74D4086a",
  get hardhat(): string {
    return this[testnet];
  }
}

export const AUSDC : AddressPerNetwork = {
  goerli: "0x1Ee669290939f8a8864497Af3BC83728715265FF",
  mumbai: "0x9daBC9860F8792AeE427808BDeF1f77eFeF0f24E",
  ethereum: "0x98C23E9d8f34FEFb1B7BD6a91B7FF122F4e16F5c",
  get hardhat(): string {
    return this[testnet];
  }
}

export const AEURS : AddressPerNetwork = {
  goerli: "0xaA63E0C86b531E2eDFE9F91F6436dF20C301963D",
  mumbai: "0x7948efE934B6a7D24B17032D81cB9CD489C68Df0",
  ethereum: "0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2",
  get hardhat(): string {
    return this[testnet];
  }
}