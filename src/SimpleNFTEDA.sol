// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {ERC721, ERC721TokenReceiver} from "solmate/tokens/ERC721.sol";
import {INFTEDA} from "NFTEDA/interfaces/INFTEDA.sol";
import {NFTEDA} from "NFTEDA/NFTEDA.sol";

contract SimpleNFTEDA is NFTEDA, ERC721TokenReceiver {
    using SafeTransferLib for ERC20;

    mapping(uint256 => uint256) auctionToStartTime;

    function onERC721Received(
        address,
        address from,
        uint256 _id,
        bytes calldata data
    ) external override returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    function startAuction(INFTEDA.Auction memory auction) public {
        auction.auctionAssetContract.safeTransferFrom(
            msg.sender,
            address(this),
            auction.auctionAssetID
        );

        _startAuction(auction);
    }

    function purchaseAuction(
        INFTEDA.Auction memory auction,
        uint256 maxPrice,
        address sendTo
    ) public returns (uint256 startTime, uint256 price) {
        uint256 id;
        (id, startTime, price) = _checkAuctionAndReturnDetails(auction);

        if (price > maxPrice) {
            revert MaxPriceTooLow(price, maxPrice);
        }

        _clearAuctionState(id);

        auction.auctionAssetContract.safeTransferFrom(
            address(this),
            sendTo,
            auction.auctionAssetID
        );

        auction.paymentAsset.safeTransferFrom(
            msg.sender,
            auction.nftOwner,
            price
        );

        emit EndAuction(id, price);
    }

    function _setAuctionStartTime(uint256 id) internal override {
        auctionToStartTime[id] = block.timestamp;
    }

    function _clearAuctionState(uint256 id) internal override {
        delete auctionToStartTime[id];
    }

    function auctionStartTime(
        uint256 id
    ) public view override returns (uint256) {
        return auctionToStartTime[id];
    }
}
