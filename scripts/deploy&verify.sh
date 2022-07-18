#!/bin/bash

network=$1

npx hardhat clean
npx hardhat run scripts/deploy.js --network $network

npx hardhat verify --network $network $(cat ./scripts/dep_args/DiamondCutFacet_address.txt)

diamonds="./scripts/dep_args/diamond_addresses.txt"
while read -r diamond
do
  npx hardhat verify --constructor-args ./scripts/dep_args/diamond_args.js --network $network "$diamond"
done < "$diamonds"

facets="./scripts/dep_args/facet_addresses.txt"
while read -r facet
do
  npx hardhat verify --network $network "$facet"
done < "$facets"

npx hardhat run scripts/deploy_dummy.js --network $network
npx hardhat verify --network $network $(cat ./scripts/dep_args/dummy_address.txt)