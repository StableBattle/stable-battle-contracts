// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { LibDiamond } from "../../shared/libraries/LibDiamond.sol";
import { IERC165 } from "../../shared/interfaces/IERC165.sol";
import { IERC173 } from "../../shared/interfaces/IERC173.sol";
import { IDiamondCut } from "../../shared/interfaces/IDiamondCut.sol";
import { IDiamondLoupe } from "../../shared/interfaces/IDiamondLoupe.sol";

import { AppStorage } from "../libraries/LibAppStorage.sol";
import { ISBVHook } from "../../StableBattle/SBVHook/ISBVHook.sol";
import { IERC721 } from "../../shared/interfaces/IERC721.sol";
import { IERC721Enumerable } from "@openzeppelin/contracts/interfaces/IERC721Enumerable.sol";


contract SBVInit {   

  AppStorage internal s;

  struct Args {
    //Premint data
      address[] premint_beneficiaries;
      uint256[] beneficiary_balances;
      uint256[] beneficiary_tokenIDs;
      address SB_address;
  }

  function SBV_init(Args memory _args) external {

    //Assign supported interfaces
    LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
    ds.supportedInterfaces[type(IERC165).interfaceId] = true;
    ds.supportedInterfaces[type(IERC173).interfaceId] = true;
    ds.supportedInterfaces[type(IERC721).interfaceId] = true;
    ds.supportedInterfaces[type(IERC721Enumerable).interfaceId] = true;

    //Assign inital facet args
    s._name = "StableBattle Villages";
    s._symbol = "SBV";
    require(_args.beneficiary_balances.length == _args.premint_beneficiaries.length,
            "SBV_init: array sizes are not equal");
    for (uint i = 0; i < _args.beneficiary_balances.length; i++) {
      s._balances[_args.premint_beneficiaries[i]] = _args.beneficiary_balances[i];
      s._owners[_args.beneficiary_tokenIDs[i]] = _args.premint_beneficiaries[i];
      //add _ownedTokens & _ownedTokensIndex & _allTokens & _allTokensIndex
    }

    //Assign StableBattle address
    s.SBHook = ISBVHook(_args.SB_address);
  }
}
