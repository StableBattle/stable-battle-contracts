// SPDX-License-Identifier: None

pragma solidity ^0.8.0;

library LzEndpointLib {
  address internal constant lzEndpointGoerli = 0xbfD2135BFfbb0B5378b56643c2Df8a87552Bfa23;
  address internal constant lzEndpointBSCTestnet = 0x6Fcb97553D41516Cb228ac03FdC8B9a0a9df04A1;

  function lzEndpoint() internal view returns(address) {
    return 
      block.chainid == 5 ? lzEndpointGoerli : 
      block.chainid == 97 ? lzEndpointBSCTestnet :
      address(0);
  }
}