// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "./vendor/Pausable.sol";

/**
* Tigers Journey To The Moon Airdrop Contract
*/
contract TJTTMAirdrop is Ownable, Pausable {
    struct Airdrop {
        address nft;
        uint id;
    }

    uint public nextAirdropId;

    mapping(uint => Airdrop) public airdrops;   // All NFT added for airdrop
    mapping(address => bool) public recipients; // List of accounts able to claim NFT

    /**
    * constructor
    */
    constructor() public {
        pause();
    }

    /**
    * @dev Add airdrops, transfers the tokens from msg.sender to airdrop contract address.
    * @param _airdrops array [
    *       { nft: <contract_address>, id: <token_id> },
    *       { nft: <contract_address>, id: <token_id> },
    * ]
    */
    function addAirdrops(Airdrop[] memory _airdrops) public onlyOwner {
        uint _nextAirdropId = nextAirdropId;
        for (uint i = 0; i < _airdrops.length; i++) {
            airdrops[_nextAirdropId] = _airdrops[i];
            IERC721(_airdrops[i].nft).transferFrom(
                msg.sender,
                address(this),
                _airdrops[i].id
            );
            _nextAirdropId++;
        }
    }

    /**
    * @dev Adds to the list of accounts able to claim NFT airdrop
    */
    function addRecipients(address[] memory _recipients) public onlyOwner {
        for (uint i = 0; i < _recipients.length; i++) {
            recipients[_recipients[i]] = true;
        }
    }

    /**
    * @dev This removes recepients from list
    */
    function removeRecipients(address[] memory _recipients) public onlyOwner {
        for (uint i = 0; i < _recipients.length; i++) {
            recipients[_recipients[i]] = false;
        }
    }

    /**
    * @dev Recipients can claim only 1 NFT
    * @dev NFT will be transfered to the caller of this function
    */
    function claim() external whenNotPaused {
        require(recipients[msg.sender] == true, 'recipient not registered');
        recipients[msg.sender] = false;
        Airdrop storage airdrop = airdrops[nextAirdropId];
        IERC721(airdrop.nft).transferFrom(address(this), msg.sender, airdrop.id);
        nextAirdropId++;
    }
}