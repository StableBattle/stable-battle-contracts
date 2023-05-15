// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

// Facets
import { AccessControlFacet } from "../src/StableBattle/Facets/AccessControl/AccessControlFacet.sol";
import { ClanFacet } from "../src/StableBattle/Facets/Clan/ClanFacet.sol";
import { DebugFacet } from "../src/StableBattle/Facets/Debug/DebugFacet.sol";
import { DiamondCutFacet } from "../src/StableBattle/Facets/DiamondCut/DiamondCutFacet.sol";
import { DiamondLoupeFacet } from "../src/StableBattle/Facets/DiamondLoupe/DiamondLoupeFacet.sol";
import { EtherscanFacet } from "../src/StableBattle/Facets/Etherscan/EtherscanFacet.sol";
import { GearFacet } from "../src/StableBattle/Facets/Gear/GearFacet.sol";
import { ItemsFacet } from "../src/StableBattle/Facets/Items/ItemsFacet.sol";
import { KnightFacet } from "../src/StableBattle/Facets/Knight/KnightFacet.sol";
import { OwnershipFacet } from "../src/StableBattle/Facets/Ownership/OwnershipFacet.sol";
import { SBVHookFacet } from "../src/StableBattle/Facets/SBVHook/SBVHookFacet.sol";
import { SiegeFacet } from "../src/StableBattle/Facets/Siege/SiegeFacet.sol";
import { TreasuryFacet } from "../src/StableBattle/Facets/Treasury/TreasuryFacet.sol";

import { IDiamondCut } from "../src/StableBattle/Facets/DiamondCut/IDiamondCut.sol";
import { DiamondInit } from "../src/StableBattle/Init&Updates/DiamondInit.sol";
import { Diamond } from "../src/StableBattle/Diamond/Diamond.sol";
import { IStableBattle } from "../src/StableBattle/Meta/IStableBattle.sol";
import { IItems } from "../src/StableBattle/Facets/Items/IItems.sol";
import { DebugFacet } from "../src/StableBattle/Facets/Debug/DebugFacet.sol";

//BEER
import { BEERImplementation } from "../src/BEER/BEERImplementation.sol";
import { BEERProxy } from "../src/BEER/BEERProxy.sol";
import { IBEER } from "../src/BEER/IBEER.sol";

//Villages
import { SBVImplementation } from "../src/SBV/SBVImplementation.sol";
import { SBVProxy } from "../src/SBV/SBVProxy.sol";
import { ISBV } from "../src/SBV/ISBV.sol";

//Helper scripts
import { DiamondHelper } from  "./DiamondHelper.s.sol";
import { Strings } from "openzeppelin-contracts/utils/Strings.sol";
import { strings } from "solidity-stringutils/strings.sol";
import { IDeployErrors } from "./IDeployErrors.s.sol";

import { console2 } from  "forge-std/console2.sol";

contract DeployStableBattle is DiamondHelper, IDeployErrors {
  using Strings for uint256;
  using strings for *;
  bool constant verbose = false;

  function deployBEER(address owner, bytes32 salt) public returns (IBEER) {
    BEERImplementation BEERImplementationContract = new BEERImplementation{salt: salt}();
    BEERProxy BEERProxyContract = new BEERProxy{salt: salt}(address(BEERImplementationContract), owner);
    IBEER BEER = IBEER(address(BEERProxyContract));
    return BEER;
  }

  function deploySBV(address owner, bytes32 salt) public returns (ISBV) {
    SBVImplementation SBVImplementationContract = new SBVImplementation{salt: salt}();
    SBVProxy SBVProxyContract = new SBVProxy{salt: salt}(address(SBVImplementationContract), owner);
    ISBV SBV = ISBV(address(SBVProxyContract));
    return SBV;
  }

  function deployStableBattle(address owner, bytes32 salt) public returns (IStableBattle, IBEER, ISBV) {
    //Deploy diamondCutFacet
    DiamondCutFacet diamondCutFacet = new DiamondCutFacet{salt: salt}();
    
    //Deploy Diamond & regen its address lib
    Diamond SBD = new Diamond{salt: salt}(owner, address(diamondCutFacet));
    IStableBattle StableBattle = IStableBattle(address(SBD));

    //Deploy BEER & regen its address lib
    IBEER BEER = deployBEER(owner, salt);

    //Deploy Villages & regen its address lib
    ISBV SBV = deploySBV(owner, salt);

    //deploy init contract
    DiamondInit diamondInit = new DiamondInit();

    // Deploy facets and add them to FacetCut array
    IDiamondCut.FacetCut[] memory cut = deployFacets();

    // Sanity checks
    for (uint i = 0; i < cut.length; i++) {
      if(cut[i].facetAddress == address(0)) {
        revert ZeroAddressInCut(i);
      }
      if(!(
        cut[i].action == IDiamondCut.FacetCutAction.Add || 
        cut[i].action == IDiamondCut.FacetCutAction.Replace ||
        cut[i].action == IDiamondCut.FacetCutAction.Remove
      )) {
        revert InvalidActionInCut(i);
      }
      if(cut[i].functionSelectors.length == 0) {
        revert NoSelectorsInCut(i);
      }
    }

    // Debug output
    if(verbose) {
      for (uint i = 0; i < cut.length; i++) {
        console2.log("Facet address: ");
        console2.logAddress(cut[i].facetAddress);
        console2.log("Facet action: ");
        console2.logUint(uint(cut[i].action));
        console2.log("Facet selectors: ");
        for (uint j = 0; j < cut[i].functionSelectors.length; j++) {
          console2.logBytes4(cut[i].functionSelectors[j]);
        }
      }
    }

    // Cut the diamond
    bytes memory initPayload = abi.encodeWithSelector(diamondInit.init.selector);
    IDiamondCut(address(SBD)).diamondCut(cut, address(diamondInit), initPayload);
    return (StableBattle, BEER, SBV);
  }

  function deployFacets() internal returns(IDiamondCut.FacetCut[] memory cut) {
    cut = new IDiamondCut.FacetCut[](12);

    cut[0] = (IDiamondCut.FacetCut({
      facetAddress: address(new AccessControlFacet()),
      action: IDiamondCut.FacetCutAction.Add,
      functionSelectors: generateSelectors(type(AccessControlFacet).name)
    }));

    cut[1] = (IDiamondCut.FacetCut({
      facetAddress: address(new ClanFacet()),
      action: IDiamondCut.FacetCutAction.Add,
      functionSelectors: generateSelectors(type(ClanFacet).name)
    }));

    cut[2] = (IDiamondCut.FacetCut({
      facetAddress: address(new DebugFacet()),
      action: IDiamondCut.FacetCutAction.Add,
      functionSelectors: generateSelectors(type(DebugFacet).name)
    }));

    cut[3] = (IDiamondCut.FacetCut({
      facetAddress: address(new DiamondLoupeFacet()),
      action: IDiamondCut.FacetCutAction.Add,
      functionSelectors: generateSelectors(type(DiamondLoupeFacet).name)
    }));

    cut[4] = (IDiamondCut.FacetCut({
      facetAddress: address(new EtherscanFacet()),
      action: IDiamondCut.FacetCutAction.Add,
      functionSelectors: generateSelectors(type(EtherscanFacet).name)
    }));

    cut[5] = (IDiamondCut.FacetCut({
      facetAddress: address(new GearFacet()),
      action: IDiamondCut.FacetCutAction.Add,
      functionSelectors: generateSelectors(type(GearFacet).name)
    }));

    cut[6] = (IDiamondCut.FacetCut({
      facetAddress: address(new ItemsFacet()),
      action: IDiamondCut.FacetCutAction.Add,
      functionSelectors:
        // Remove redundant supportsInterface selector
        removeElement(
          bytes4(keccak256(bytes("supportsInterface(bytes4)"))),
          generateSelectors(type(ItemsFacet).name)
        )
    }));

    cut[7] = (IDiamondCut.FacetCut({
      facetAddress: address(new KnightFacet()),
      action: IDiamondCut.FacetCutAction.Add,
      functionSelectors: generateSelectors(type(KnightFacet).name)
    }));

    cut[8] = (IDiamondCut.FacetCut({
      facetAddress: address(new OwnershipFacet()),
      action: IDiamondCut.FacetCutAction.Add,
      functionSelectors: generateSelectors(type(OwnershipFacet).name)
    }));

    cut[9] = (IDiamondCut.FacetCut({
      facetAddress: address(new SBVHookFacet()),
      action: IDiamondCut.FacetCutAction.Add,
      functionSelectors: generateSelectors(type(SBVHookFacet).name)
    }));

    cut[10] = (IDiamondCut.FacetCut({
      facetAddress: address(new SiegeFacet()),
      action: IDiamondCut.FacetCutAction.Add,
      functionSelectors: generateSelectors(type(SiegeFacet).name)
    }));

    cut[11] = (IDiamondCut.FacetCut({
      facetAddress: address(new TreasuryFacet()),
      action: IDiamondCut.FacetCutAction.Add,
      functionSelectors: generateSelectors(type(TreasuryFacet).name)
    }));

    return cut;
  }
}