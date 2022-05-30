// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.10;

import { AppStorage } from "../libraries/LibAppStorage.sol";


contract SBVInit {   

  AppStorage internal s;

  struct Args {
    string name;
    string symbol;
    //premint data
      address[] premint_beneficiaries;
      uint256[] beneficiaries_balances;
      uint256[] beneficiary_tokenIDs;
  }

  function SB_init(Args memory _args) external {
    s._name = _args.name;
    s._symbol = _args.symbol;
    require(_args.beneficiaries_balances.length == _args.premint_beneficiaries.length,
            "SBAppStorageInit: array sizes are not equal");
    for (uint i = 0; i < _args.beneficiaries_balances.length; i++) {
      s._balances[_args.premint_beneficiaries[i]] = _args.beneficiaries_balances[i];
      s._owners[_args.beneficiary_tokenIDs[i]] = _args.premint_beneficiaries[i];
      //add _ownedTokens & _ownedTokensIndex & _allTokens & _allTokensIndex
    }
  }
}
