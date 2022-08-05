// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import { LibDiamond } from "../../shared/libraries/LibDiamond.sol";
import { IERC165 } from "../../shared/interfaces/IERC165.sol";
import { IERC173 } from "../../shared/interfaces/IERC173.sol";
import { IDiamondCut } from "../../shared/interfaces/IDiamondCut.sol";
import { IDiamondLoupe } from "../../shared/interfaces/IDiamondLoupe.sol";

import { AppStorage } from "../libraries/LibAppStorage.sol";
import { IClan } from "../../StableBattle/Clan/IClan.sol";
import { IERC20 } from "../../shared/interfaces/IERC20.sol";
import { ISBT } from "../../shared/interfaces/ISBT.sol";

contract SBTInit {   

  AppStorage internal s;

  struct Args {
    address SBD_address;
    //premint data
      address[] premint_beneficiaries;
      uint256[] beneficiaries_balances;
      uint256 totalSupplyPremint;
  }

  function SBT_init(Args memory _args) external {

    //Assign supported interfaces
    LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
    ds.supportedInterfaces[type(IERC165).interfaceId] = true;
    ds.supportedInterfaces[type(IERC173).interfaceId] = true;
    ds.supportedInterfaces[type(IERC20).interfaceId] = true;
    ds.supportedInterfaces[type(ISBT).interfaceId] = true;

    //Assign inital facet args
    s._name = "Stable Battle Token";
    s._symbol = "SBT";
    s._decimals = 18;
    s._totalSupply = _args.totalSupplyPremint;
    require(_args.beneficiaries_balances.length == _args.premint_beneficiaries.length,
            "SBT_init: array sizes are not equal");
    for (uint i = 0; i < _args.beneficiaries_balances.length; i++) {
      s._balances[_args.premint_beneficiaries[i]] = _args.beneficiaries_balances[i];
    }
    s.SBD = _args.SBD_address;
    s.ClanFacet = IClan(s.SBD);
  }
}