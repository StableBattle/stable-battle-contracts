// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

import { IERC20 } from "../../shared/interfaces/IERC20.sol";
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { ISBT } from "../../shared/interfaces/ISBT.sol";
import { ISBV } from "../../shared/interfaces/ISBV.sol";

library MetaStorage {

	struct Layout {
		// StableBattle EIP20 Token address
		ISBT SBT;
		// StableBattle EIP721 Village address
		ISBV SBV;

		IERC20 USDT;
		IPool AAVE;

		//Villages information (to reduce calls from Treasury)
    uint villageAmount;
    mapping (uint => address) villageOwner;
	}

	bytes32 internal constant STORAGE_SLOT = keccak256("StableBattle.storage");

	function layout() internal pure returns (Layout storage l) {
		bytes32 slot = STORAGE_SLOT;
		assembly {
			l.slot := slot
		}
	}
}
