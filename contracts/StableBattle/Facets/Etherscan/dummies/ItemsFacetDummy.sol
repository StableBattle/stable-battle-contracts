// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

contract ItemsFacetDummy {

//ERC1155
  function balanceOf(address account, uint256 id)
    external
    view
    returns (uint256) {}
      
  function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
    external
    view
    returns (uint256[] memory) {}
      
  function isApprovedForAll(address account, address operator)
    external
    view
    returns (bool) {}
      
  function setApprovalForAll(address operator, bool status) external {}
  
  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes calldata data
  ) external {}
  
  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] calldata ids,
    uint256[] calldata amounts,
    bytes calldata data
  ) external {}

//ERC1155Enumerable
  function totalSupply(uint256 id) external view returns (uint256) {}
  
  function totalHolders(uint256 id) external view returns (uint256) {}
  
  function accountsByToken(uint256 id)
      external
      view
      returns (address[] memory) {}
      
  function tokensByAccount(address account)
      external
      view
      returns (uint256[] memory) {}

//ERC1155Metadata
  function uri(uint256 tokenId) external view returns (string memory) {}
}