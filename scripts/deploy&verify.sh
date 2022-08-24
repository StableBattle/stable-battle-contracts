#!/bin/bash

network=$1

#Deploy StableBattle
npx hardhat clean
npx hardhat run scripts/deploy.js --network $network

#Verify addresses of all diamonds
contracts="./scripts/config/$network/main-contracts.txt"
while read -r contract
do
  npx hardhat verify --constructor-args ./scripts/config/diamond_args.js --network $network "$contract"
done < "$contracts"

#Verify addresses of all facets
facets="./scripts/config/$network/sb-facets.txt"
while read -r facet
do
  npx hardhat verify --network $network "$facet"
done < "$facets"

#Deploy & verify dummy address for etherscan compatibility
npx hardhat run scripts/deploy_dummy.js --network $network
npx hardhat verify --network $network $(cat ./scripts/config/$network/dummy-address.txt)