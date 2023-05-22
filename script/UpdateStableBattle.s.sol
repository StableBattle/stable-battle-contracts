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
import { DebugFacet } from "../src/StableBattle/Facets/Debug/DebugFacet.sol";

// Interfaces & Libraries
import { IDiamondCut } from "../src/StableBattle/Facets/DiamondCut/IDiamondCut.sol";
import { IDiamondLoupe } from "../src/StableBattle/Facets/DiamondLoupe/IDiamondLoupe.sol";
import { IStableBattle } from "../src/StableBattle/Meta/IStableBattle.sol";
import { IItems } from "../src/StableBattle/Facets/Items/IItems.sol";
import { DiamondAddressLib } from "../src/StableBattle/Init&Updates/DiamondAddressLib.sol";

//BEER
import { IBEER } from "../src/BEER/IBEER.sol";
import { BEERAddressLib } from "../src/StableBattle/Init&Updates/BEERAddressLib.sol";

//Villages
import { ISBV } from "../src/SBV/ISBV.sol";
import { SBVAddressLib } from "../src/StableBattle/Init&Updates/SBVAddressLib.sol";

//Helper scripts
import { DiamondHelper } from  "./DiamondHelper.s.sol";
import { strings } from "solidity-stringutils/strings.sol";

import { console2 } from  "forge-std/console2.sol";

contract UpdateStableBattle is DiamondHelper {
  using strings for *;
  IStableBattle constant StableBattle = IStableBattle(DiamondAddressLib.DiamondAddress);
  IBEER constant BEER = IBEER(BEERAddressLib.BEERAddress);
  ISBV constant SBV = ISBV(SBVAddressLib.SBVAddress);

  function run() public {
    updateStableBattle();
  }

  function updateStableBattle() public {
    IDiamondCut.FacetCut[] memory cut = generateDiamondCut(StableBattle.facets());
    StableBattle.diamondCut(cut, address(0), "0x");
  }

  function generateDiamondCut(
    IDiamondLoupe.Facet[] memory facets
  ) internal returns (IDiamondCut.FacetCut[] memory cut) {
    //Genereate big array of all possible cuts
    IDiamondCut.FacetCut[] memory preCut = new IDiamondCut.FacetCut[](facets.length * 3);
    uint256 cutIndex = 0;
    //"Iterate" over facets and generate cuts
    //AccessControl
    IDiamondCut.FacetCut[] memory AccessControlCut = generateFacetCut(
      facets,
      address(new AccessControlFacet()),
      type(AccessControlFacet).name
    );
    for(uint256 i = 0; i < AccessControlCut.length; i++) {
      preCut[cutIndex] = AccessControlCut[i];
      cutIndex++;
    }
    //Clan
    IDiamondCut.FacetCut[] memory ClanCut = generateFacetCut(
      facets,
      address(new ClanFacet()),
      type(ClanFacet).name
    );
    for(uint256 i = 0; i < ClanCut.length; i++) {
      preCut[cutIndex] = ClanCut[i];
      cutIndex++;
    }
    //DiamondCut
    /*
    IDiamondCut.FacetCut[] memory DiamondCutCut = generateFacetCut(
      facets,
      address(new DiamondCutFacet()),
      type(DiamondCutFacet).name
    );
    for(uint256 i = 0; i < DiamondCutCut.length; i++) {
      preCut[cutIndex] = DiamondCutCut[i];
      cutIndex++;
    }
    */
    //DiamondLoupe
    /*
    IDiamondCut.FacetCut[] memory DiamondLoupeCut = generateFacetCut(
      facets,
      address(new DiamondLoupeFacet()),
      type(DiamondLoupeFacet).name
    );
    for(uint256 i = 0; i < DiamondLoupeCut.length; i++) {
      preCut[cutIndex] = DiamondLoupeCut[i];
      cutIndex++;
    }
    */
    //Etherscan
    /*
    IDiamondCut.FacetCut[] memory EtherscanCut = generateFacetCut(
      facets,
      address(new EtherscanFacet()),
      type(EtherscanFacet).name
    );
    for(uint256 i = 0; i < EtherscanCut.length; i++) {
      preCut[cutIndex] = EtherscanCut[i];
      cutIndex++;
    }
    */
    //Gear
    IDiamondCut.FacetCut[] memory GearCut = generateFacetCut(
      facets,
      address(new GearFacet()),
      type(GearFacet).name
    );
    for(uint256 i = 0; i < GearCut.length; i++) {
      preCut[cutIndex] = GearCut[i];
      cutIndex++;
    }
    //Items
    IDiamondCut.FacetCut[] memory ItemsCut = generateFacetCut(
      facets,
      address(new ItemsFacet()),
      type(ItemsFacet).name
    );
    for(uint256 i = 0; i < ItemsCut.length; i++) {
      preCut[cutIndex] = ItemsCut[i];
      cutIndex++;
    }
    //Knight
    IDiamondCut.FacetCut[] memory KnightCut = generateFacetCut(
      facets,
      address(new KnightFacet()),
      type(KnightFacet).name
    );
    for(uint256 i = 0; i < KnightCut.length; i++) {
      preCut[cutIndex] = KnightCut[i];
      cutIndex++;
    }
    //Ownership
    /*
    IDiamondCut.FacetCut[] memory OwnershipCut = generateFacetCut(
      facets,
      address(new OwnershipFacet()),
      type(OwnershipFacet).name
    );
    for(uint256 i = 0; i < OwnershipCut.length; i++) {
      preCut[cutIndex] = OwnershipCut[i];
      cutIndex++;
    }
    */
    //SBVHook
    IDiamondCut.FacetCut[] memory SBVHookCut = generateFacetCut(
      facets,
      address(new SBVHookFacet()),
      type(SBVHookFacet).name
    );
    for(uint256 i = 0; i < SBVHookCut.length; i++) {
      preCut[cutIndex] = SBVHookCut[i];
      cutIndex++;
    }
    //Siege
    IDiamondCut.FacetCut[] memory SiegeCut = generateFacetCut(
      facets,
      address(new SiegeFacet()),
      type(SiegeFacet).name
    );
    for(uint256 i = 0; i < SiegeCut.length; i++) {
      preCut[cutIndex] = SiegeCut[i];
      cutIndex++;
    }
    //Treasury
    IDiamondCut.FacetCut[] memory TreasuryCut = generateFacetCut(
      facets,
      address(new TreasuryFacet()),
      type(TreasuryFacet).name
    );
    for(uint256 i = 0; i < TreasuryCut.length; i++) {
      preCut[cutIndex] = TreasuryCut[i];
      cutIndex++;
    }
    cut = new IDiamondCut.FacetCut[](cutIndex);
    for(uint256 i = 0; i < cutIndex; i++) {
      cut[i] = preCut[i];
    }
  }

  function generateFacetCut(
    IDiamondLoupe.Facet[] memory facets,
    address facetAddress,
    string memory facetName
  ) internal returns(IDiamondCut.FacetCut[] memory cut) 
{
    bytes4[] memory selectors = generateSelectors(facetName);
    // Find facet to replace
    uint256 facetIndex;
    for (uint256 i = 0; i < facets.length; i++) {
      for(uint256 j = 0; j < facets[i].functionSelectors.length; j++) {
        for(uint256 k = 0; k < selectors.length; k++) {
          if(facets[i].functionSelectors[j] == selectors[k]) {
            facetIndex = i;
            break;
          }
        }
      }
    }
    IDiamondLoupe.Facet memory oldFacet = facets[facetIndex];
    bytes4[] memory oldSelectors = oldFacet.functionSelectors;
    // Find selectors to add
    bytes4[] memory _selectorsToAdd = new bytes4[](selectors.length);
    uint256 selectorsToAddLength = 0;
    for(uint256 i = 0; i < selectors.length; i++) {
      bool found = false;
      for(uint256 j = 0; j < oldSelectors.length; j++) {
        if(selectors[i] == oldSelectors[j]) {
          found = true;
          break;
        }
      }
      if(!found) {
        _selectorsToAdd[selectorsToAddLength] = selectors[i];
        selectorsToAddLength++;
      }
    }
    bytes4[] memory selectorsToAdd = new bytes4[](selectorsToAddLength);
    for(uint256 i = 0; i < selectorsToAddLength; i++) {
      selectorsToAdd[i] = _selectorsToAdd[i];
    }
    // Find selectors to replace
    bytes4[] memory _selectorsToReplace = new bytes4[](selectors.length);
    uint256 selectorsToReplaceLength = 0;
    for(uint256 i = 0; i < selectors.length; i++) {
      bool found = false;
      for(uint256 j = 0; j < oldSelectors.length; j++) {
        if(selectors[i] == oldSelectors[j]) {
          found = true;
          break;
        }
      }
      if(found) {
        _selectorsToReplace[selectorsToReplaceLength] = selectors[i];
        selectorsToReplaceLength++;
      }
    }
    bytes4[] memory selectorsToReplace = new bytes4[](selectorsToReplaceLength);
    for(uint256 i = 0; i < selectorsToReplaceLength; i++) {
      selectorsToReplace[i] = _selectorsToReplace[i];
    }
    // Find selectors to remove
    bytes4[] memory _selectorsToRemove = new bytes4[](oldSelectors.length);
    uint256 selectorsToRemoveLength = 0;
    for(uint256 i = 0; i < oldSelectors.length; i++) {
      bool found = false;
      for(uint256 j = 0; j < selectors.length; j++) {
        if(oldSelectors[i] == selectors[j]) {
          found = true;
          break;
        }
      }
      if(!found) {
        _selectorsToRemove[selectorsToRemoveLength] = oldSelectors[i];
        selectorsToRemoveLength++;
      }
    }
    bytes4[] memory selectorsToRemove = new bytes4[](selectorsToRemoveLength);
    for(uint256 i = 0; i < selectorsToRemoveLength; i++) {
      selectorsToRemove[i] = _selectorsToRemove[i];
    }
    //Generate cut[] from selectors
    uint256 cutLength = 
      selectorsToAddLength == 0 ? 0 : 1 + 
      selectorsToReplaceLength == 0 ? 0 : 1 + 
      selectorsToRemoveLength == 0 ? 0 : 1;
    cut = new IDiamondCut.FacetCut[](cutLength);
    uint256 cutIndex = 0;
    if(selectorsToAddLength > 0) {
      cut[cutIndex] = (IDiamondCut.FacetCut({
        facetAddress: facetAddress,
        action: IDiamondCut.FacetCutAction.Add,
        functionSelectors: selectorsToAdd
      }));
      cutIndex++;
    }
    if(selectorsToReplaceLength > 0) {
      cut[cutIndex] = (IDiamondCut.FacetCut({
        facetAddress: facetAddress,
        action: IDiamondCut.FacetCutAction.Replace,
        functionSelectors: selectorsToReplace
      }));
      cutIndex++;
    }
    if(selectorsToRemoveLength > 0) {
      cut[cutIndex] = (IDiamondCut.FacetCut({
        facetAddress: address(0),
        action: IDiamondCut.FacetCutAction.Remove,
        functionSelectors: selectorsToRemove
      }));
      cutIndex++;
    }
  }
}