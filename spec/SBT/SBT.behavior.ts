import { 
  describeBehaviorOfSolidStateERC20, 
  SolidStateERC20BehaviorArgs
} from "@solidstate/spec/dist/token/ERC20/SolidStateERC20.behavior";

import { describeFilter } from '@solidstate/library';
import { ISBT } from "../../typechain-types"
import { BigNumber, BigNumberish, ContractTransaction } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

export interface SBTBehaviorArgs
  extends SolidStateERC20BehaviorArgs {
    adminMint: (address: string, amount: BigNumber) => Promise<ContractTransaction>;
    adminBurn: (address: string, amount: BigNumber) => Promise<ContractTransaction>;
    treasuryMint: (address: string[], amount: BigNumber[]) => Promise<ContractTransaction>;
    stake: (clanId: BigNumber, amount: BigNumber) => Promise<ContractTransaction>;
    withdraw: (clanId: BigNumber, amount: BigNumber) => Promise<ContractTransaction>;

  }