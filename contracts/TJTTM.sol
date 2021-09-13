// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title Tigers Journey To The Moon contract
 * @dev Extends ERC721 Non-Fungible Token Standard basic implementation
 */
contract TJTTM is ERC721, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    uint256 public MAX_SUPPLY = 10000;            // Max supply

    /**
     * Constructor
     */
    constructor() ERC721("Tigers Journey To The Moon", "TJTTM") public {
        //
    }

    function maxSupply() view public returns(uint256) {
        return MAX_SUPPLY;
    }

    /**
     * Set base URI for NFTs
     */
    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    /**
     * Set token URI for collectible
     * This should be action url if baseURI is set.
     */
    function setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyOwner {
        _setTokenURI(tokenId, _tokenURI);
    }

    /**
    * @dev Mint single NFT
    */
    function mintTiger(address toAccount) public onlyOwner {
        require(toAccount != address(0));
        require(totalSupply() < MAX_SUPPLY, "Max supply reached!");

        uint256 newItemId = _tokenIds.current();
        _safeMint(toAccount, newItemId);

        _tokenIds.increment();
    }

    /**
    * @dev Mint NFTs in bulk
    */
    function mintInBulk(uint256 _numOfTokens, address toAccount) public onlyOwner {
        require(toAccount != address(0));
        require(_numOfTokens <= 20, "Can only mint 20 tokens at a time");
        require(totalSupply().add(_numOfTokens) < MAX_SUPPLY, "Max supply reached!");

        for(uint i = 0; i < _numOfTokens; i++) {
            mintTiger(toAccount);
        }
    }

    /**
    * @dev Burn NFT by giving tokenId.
    * @dev Able to burn only if owner of NFT or approved to NFT
    */
    function burnTiger(uint256 tokenId) public onlyOwner {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721Burnable: caller is not owner nor approved"
        );

        _burn(tokenId);
    }
}