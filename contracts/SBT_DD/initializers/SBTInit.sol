// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import { AppStorage } from "../libraries/LibAppStorage.sol";
import { IClan } from "../../shared/interfaces/IClan.sol";


contract SBTInit {   

  AppStorage internal s;

  struct Args {
    string name;
    string symbol;
    uint8 decimals;
    address[] minters;
    address[] burners;
    address ClanFacetAddress;
    //premint data
      address[] premint_beneficiaries;
      uint256[] beneficiaries_balances;
      uint256 totalSupplyPremint;
  }

  function SB_init(Args memory _args) external {
    s._name = _args.name;
    s._symbol = _args.symbol;
    s._decimals = _args.decimals;
    s._totalSupply = _args.totalSupplyPremint;
    require(_args.beneficiaries_balances.length == _args.premint_beneficiaries.length,
            "SBAppStorageInit: array sizes are not equal");
    for (uint i = 0; i < _args.beneficiaries_balances.length; i++) {
      s._balances[_args.premint_beneficiaries[i]] = _args.beneficiaries_balances[i];
    }
    s.minters = _args.minters;
    s.burners = _args.burners;

    s.ClanFacet = IClan(_args.ClanFacetAddress);
  }
}
