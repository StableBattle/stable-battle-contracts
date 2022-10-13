## StableBattle Contracts
### General contract layout
The project is built using EIP-2535 Diamond architecture.
The Diamond contract serves as an entry point to the StableBattle ecosystem.
The functionality is split into several chunks called "facets" based upon their purpose. This is intended to both sircumvent 24Kb contract size limit and make the entire project more comprehensible to auditors and contributors.
Facets functionality are as follows:
- Admin -- debug functions to quickly tweak some part of the contract
- AccessControl -- adding and removing roles that limit calls to specific functions to a particular set of addresses.
- Clan -- joining, leaving, staking and all other clan related functionality
- DemoFight -- funcitonality that supports battles in 1v1 mode
- DiamondCut -- an upgrade functionality. Part of EIP-2535 standart.
- DiamondLoupe -- info about proxy structure. Part of EIP-2535 standart.
- Etherscan -- a hack that enables a proper representation of SB interfaces on etherscan
- Gear -- functionality related to knights gear including minting and equipping
- Items -- EIP1155 implementaton (with some additional functionality in the future)
- Knight -- all knight related functons including minting, burning and all possible getters
- Ownership -- ERC173 implementation. Part of EIP-2535 standart.
- SBVHook -- a hook that updates SB info when someones village changes hands
- Tournament -- basic functionality of updating castle holder a lot TBD
- Treasury -- mint and distribute rewards for village owners & castle holder
### Facet structure
Each individual facet consist out of several files that follow a common structure. Lets take a closer look at the Clan facet as an example:
- ClanStorage -- a storage layout for all variables related to this facet. Most facets have their own storage for the ease of upgradeability in the future
- ClanGetters -- an abstract contract that contains pull all the information we would need from the ClanStorage. All functions here are internal thus could only be called inside the contract code and not from the outside the blockchain
- ClanModifiers -- all the modifiers and various boolean check-up functions related to the StableBattle clans
- ClanInternal -- the core functionality of the facet. All of the functions are intended to be used in any facet. Thus all of them are intenral to not mess up other facet interfaces
- ClanFacet -- the contract that is actuallly added to the diamond. In essense it is merely a gateway to the ClanInternal and ClanGetters with the appropriate modifiers 
- ClanFacetDummy -- a dummy contract with whose interfaces are an exact match to the ClanFacet. Used to create the combined abi from all the facets. The combined version also deployed as a mock contract to trick etherscan UI into showing correct intrafaces for the diamond.
- IClanEvents -- all the events ClanFacet may emit.
- IClanErrors -- all custom errors ClanFacet may throw
- IClan -- ClanFacet public interface