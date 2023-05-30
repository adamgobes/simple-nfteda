// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {SimpleNFTEDA} from "src/SimpleNFTEDA.sol";

contract DeploySimpleNFTEDA is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        SimpleNFTEDA auctionContract = new SimpleNFTEDA();
        vm.stopBroadcast();
    }
}
