// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "openzeppelin-contracts/utils/introspection/IERC165.sol";
import { ERC20BaseInternal } from "solidstate-solidity/token/ERC20/base/ERC20BaseInternal.sol";
import { ERC20BaseStorage } from "solidstate-solidity/token/ERC20/base/ERC20BaseStorage.sol";
import "./IOFT.sol";
import "./OFTCore.sol";

// override decimal() function is needed
contract OFT is ERC20BaseInternal, OFTCore {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IOFT).interfaceId || interfaceId == type(IERC20).interfaceId || super.supportsInterface(interfaceId);
    }

    function token() public view virtual override returns (address) {
        return address(this);
    }

    function circulatingSupply() public view virtual override returns (uint) {
        return _totalSupply();
    }

    function _debitFrom(address _from, uint16, bytes memory, uint _amount) internal virtual override returns(uint) {
        address spender = msg.sender;
        if (_from != spender) {
            uint256 currentAllowance = ERC20BaseStorage.layout().allowances[_from][spender];
            ERC20BaseStorage.layout().allowances[_from][spender] = currentAllowance - _amount;
        }
        _burn(_from, _amount);
        return _amount;
    }

    function _creditTo(uint16, address _toAddress, uint _amount) internal virtual override returns(uint) {
        _mint(_toAddress, _amount);
        return _amount;
    }
}
