#!/bin/bash
npx hardhat clean

npx hardhat run scripts/deploy.js --network polygonMumbai

#npx hardhat verify --constructor-args ./scripts/dep_token_args.js --network polygonMumbai $(cat .token_addr)
#npx hardhat verify --constructor-args ./scripts/dep_treasury_args.js --network polygonMumbai $(cat .treasury_addr)

