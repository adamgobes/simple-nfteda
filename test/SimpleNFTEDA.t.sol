pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {SimpleNFTEDA} from "src/SimpleNFTEDA.sol";
import {NFTEDA} from "NFTEDA/NFTEDA.sol";
import {INFTEDA} from "NFTEDA/interfaces/INFTEDA.sol";
import {TestERC721} from "./TestERC721.sol";
import {TestERC20} from "./TestERC20.sol";

contract SimpleNFTEDATest is Test {
    NFTEDA.Auction auction;
    TestERC721 nft = new TestERC721();
    TestERC20 erc20 = new TestERC20();
    SimpleNFTEDA auctionContract = new SimpleNFTEDA();
    address nftOwner = address(0xdad);
    uint256 nftId = 1;
    uint256 decay = 0.9e18;
    uint256 secondsInPeriod = 1 days;
    uint256 startPrice = 1e18;
    address purchaser = address(0xb0b);

    function setUp() public {
        auction = INFTEDA.Auction({
            nftOwner: nftOwner,
            auctionAssetID: nftId,
            auctionAssetContract: nft,
            perPeriodDecayPercentWad: decay,
            secondsInPeriod: secondsInPeriod,
            startPrice: startPrice,
            paymentAsset: erc20
        });
        nft.mint(nftOwner, nftId);
        vm.prank(nftOwner);
        nft.approve(address(auctionContract), nftId);

        erc20.mint(purchaser, startPrice);
        vm.prank(purchaser);
        erc20.approve(address(auctionContract), startPrice);
    }

    function testStartAuctionTransfersNFTCorrectly() public {
        _startTestAuction();
        assertEq(nft.ownerOf(auction.auctionAssetID), address(auctionContract));

        uint256 auctionId = auctionContract.auctionID(auction);
        assertEq(auctionContract.auctionStartTime(auctionId), block.timestamp);
    }

    function testEndAuctionTransfersAssetsAndEndsAuctionCorrectly() public {
        _startTestAuction();
        uint256 auctionId = auctionContract.auctionID(auction);
        uint256 currentPrice = auctionContract.auctionCurrentPrice(auction);

        vm.prank(purchaser);
        (, uint256 auctionPrice) = auctionContract.purchaseAuction(
            auction,
            currentPrice,
            purchaser
        );

        assertEq(erc20.balanceOf(purchaser), startPrice - auctionPrice);
        assertEq(erc20.balanceOf(nftOwner), auctionPrice);
        assertEq(nft.ownerOf(auction.auctionAssetID), purchaser);
        assertEq(auctionContract.auctionStartTime(auctionId), 0);
    }

    function _startTestAuction() internal {
        vm.prank(nftOwner);
        auctionContract.startAuction(auction);
    }
}
