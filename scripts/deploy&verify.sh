#!/bin/bash

npx hardhat clean
npx hardhat run scripts/deploy.js --network polygonMumbai

npx hardhat verify --network polygonMumbai $(cat ./scripts/dep_args/DiamondCutFacet_address.txt)

diamonds="./scripts/dep_args/diamond_addresses.txt"
while read -r diamond
do
  npx hardhat verify --constructor-args ./scripts/dep_args/diamond_args.js --network polygonMumbai "$diamond"
  #npx hardhat run scripts/dep_args/diamond_args.js
done < "$diamonds"

facets="./scripts/dep_args/facet_addresses.txt"
while read -r facet
do
  npx hardhat verify --network polygonMumbai "$facet"
done < "$facets"

npx hardhat run scripts/deploy_dummy.js --network polygonMumbai
npx hardhat verify --network polygonMumbai $(cat ./scripts/dep_args/dummy_address.txt)