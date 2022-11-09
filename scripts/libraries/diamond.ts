import { Contract } from "ethers"
import { ethers } from "hardhat"

export enum FacetCutAction {
  Add,
  Replace,
  Remove
}

// get function selectors from ABI
export default function getSelectors (contract : Contract) : string[] {
  const signatures = Object.keys(contract.interface.functions)
  const selectors = signatures.reduce((acc, val) => {
    if (val !== 'init(bytes)') {
      acc.push(contract.interface.getSighash(val))
    }
    return acc
  }, <string[]>[])
  return selectors;
}

// get function selector from function signature
export function getSelector (functionName : string) : string {
  const abiInterface = new ethers.utils.Interface([functionName])
  return abiInterface.getSighash(ethers.utils.Fragment.from(functionName))
}

export class DiamondSelectors {
  selectors: string[];
  contract: Contract;
  constructor(_contract: Contract) {
    this.contract = _contract
    this.selectors = getSelectors(this.contract)
  }
  // used to remove selectors from an array of selectors
  // signatures argument is an array of function signatures
  removeBySignature(signatures : string[]) {
    this.selectors = this.selectors.filter((selector) => {
      for (const functionName of signatures) {
        if (selector === this.contract.interface.getSighash(functionName)) {
          return false
        }
      }
      return true
    })
    return this;
  }
  // used to get selectors from an array of selectors
  // signatures argument is an array of function signatures
  filterBySignature(signatures : string[]) {
    this.selectors = this.selectors.filter((selector) => {
      for (const functionName of signatures) {
        if (selector === this.contract.interface.getSighash(functionName)) {
          return true
        }
      }
      return false
    })
    return this;
  }
}

// remove selectors using an array of signatures
export function removeSelectors (selectors : string[], signatures : string[]) {
  const iface = new ethers.utils.Interface(signatures.map(v => 'function ' + v))
  const removeSelectors = signatures.map(v => iface.getSighash(v))
  selectors = selectors.filter(v => !removeSelectors.includes(v))
  return selectors
}

// find a particular address position in the return value of diamondLoupeFacet.facets()
export function findAddressPositionInFacets (facetAddress : string, facets : Contract[]) {
  for (let i = 0; i < facets.length; i++) {
    if (facets[i].facetAddress === facetAddress) {
      return i
    }
  }
}
