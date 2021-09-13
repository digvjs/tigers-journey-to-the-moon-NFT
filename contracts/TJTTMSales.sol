// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./vendor/Pausable.sol";
import "./TJTTM.sol";

contract TJTTMSales is Ownable, Pausable {
    using SafeMath for uint256;
    using Address for address;

    event Sent(address indexed payee, uint256 amount, uint256 balance);
    event Purchased(address indexed payer, uint256 numberOfTokens, uint256 amount);

    enum SaleStage { STAGE_1, STAGE_2 }     // ids are 0 and 1

    SaleStage public stage = SaleStage.STAGE_1;     // Default to sale stage_1

    uint256 public maxPurchase = 20;    // Max number of Tigers can be minted per batch
    uint256 public rate = 0.09 * 1E18;        // Price for buying single NFT (in eth)
    uint256 public cap = 1000;          // Maximum tokens that can be purchased
    uint256 public saleStartTime;

    mapping(uint => uint) numOfTokensSold;

    TJTTM public nftAddress;

    constructor(address _nftAddress, uint256 _saleStartTime) public {
        require(_nftAddress != address(0) && _nftAddress != address(this));
        nftAddress = TJTTM(_nftAddress);
        saleStartTime = _saleStartTime;
    }

    /**
    * @dev Allows admin to update the sale stage
    * @param _stage sale stage
    */
    function setSaleStage(uint _stage) public onlyOwner {
        if(uint(SaleStage.STAGE_1) == _stage) {
            stage = SaleStage.STAGE_1;
            rate = 0.09 * 1E18;
        } else if (uint(SaleStage.STAGE_2) == _stage) {
            stage = SaleStage.STAGE_2;
            rate = 1.23 * 1E18;
        }
    }

    /**
    * @dev Purchase token
    * @param _numberOfTokens uint256 Number of tokens
    */
    function purchaseToken(uint256 _numberOfTokens) public payable whenNotPaused {
        require(msg.sender != address(0) && msg.sender != address(this));
        require(saleStartTime <= block.timestamp, "Sale is not started!");
        require(rate.mul(_numberOfTokens) <= msg.value, "Ether value sent is not correct.");
        require(numOfTokensSold[uint256(stage)].add(_numberOfTokens) <= cap, "Purchase exceeding maximum cap.");

        nftAddress.mintInBulk(_numberOfTokens, msg.sender);

        numOfTokensSold[uint256(stage)] = numOfTokensSold[uint256(stage)].add(_numberOfTokens);

        emit Purchased(msg.sender, _numberOfTokens, msg.value);
    }

    /**
     *  @dev end sale
     *  @dev transfer ownership to the owner of current contract
     *  @dev pauses the sale
     */
    function endSale() public onlyOwner {
        require(!address(msg.sender).isContract(), "Contract cannot call this function!");
        nftAddress.transferOwnership(msg.sender);
        pause();
    }

    /**
    * @dev Updates _rate
    * @dev Throws if _rate is zero
    */
    function setRate(uint256 _rate) public onlyOwner {
        require(_rate > 0);
        rate = _rate;
    }

    /**
    * @dev Updates cap
    */
    function setCap(uint256 _cap) public onlyOwner {
        require(_cap > 0);
        cap = _cap;
    }

    /**
     * @dev Update sale start Time
     */
    function setSaleStartTime(uint256 _saleStartTime) public onlyOwner {
        saleStartTime = _saleStartTime;
    }

    /**
    * @dev Withdraw Ethers from smart contract
    */
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0);

        msg.sender.transfer(balance);
    }

}