"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");
const privateKey = '0xed0872e555a2f377942e30b322c1edad2b4a6d03ddf0e171d2e18a56c7dc80d2';
const config = {
    solidity: "0.8.9",
    networks: {
        binanceTestnet: {
            url: 'https://data-seed-prebsc-1-s1.binance.org:8545',
            accounts: [privateKey]
        }
    }
};
exports.default = config;
