// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

library LzChainIdsLib {
  // Mainnets
  uint16 constant internal ethereumLzChainId = 101;
  uint16 constant internal bscLzChainId = 102;
  uint16 constant internal avalancheLzChainId = 106;
  uint16 constant internal polygonLzChainId = 109;
  uint16 constant internal arbitrumLzChainId = 110;
  uint16 constant internal optimismLzChainId = 111;
  uint16 constant internal fantomLzChainId = 112;

  // Testnets
  uint16 constant internal goerliLzChainId = 10121;
  uint16 constant internal bscTestnetLzChainId = 10102;
  uint16 constant internal fujiLzChainId = 10106;
  uint16 constant internal mumbaiLzChainId = 10109;
  uint16 constant internal arbitrumGoerliLzChainId = 10143;
  uint16 constant internal optimismGoerliLzChainId = 10132;
  uint16 constant internal fantomTestnetLzChainId = 10112;
  uint16 constant internal meterTestnetLzChainId = 10156;
  uint16 constant internal zksyncTestnetLzChainId = 10165;
}