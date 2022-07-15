// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @custom:security-contact sumit@sumit-ghosh.com
contract MetadriveFile is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Burnable
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // For each tokenized file, store the encrypted symmetric key
    mapping(uint256 => mapping(address => bytes32)) public keys;

    // Checks if the caller is the NFT owner
    modifier callerIsOwner(uint256 tokenId) {
        require(
            msg.sender == ownerOf(tokenId),
            "Caller does not own the token."
        );
        _;
    }

    constructor() ERC721("MetadriveFile", "MDF") {}

    function safeMint(string memory uri, bytes32 key) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
        keys[tokenId][msg.sender] = key;
    }

    function share(uint256 tokenId, address to) public callerIsOwner(tokenId) {
        delete keys[tokenId][to];
    }

    function unshare(
        uint256 tokenId,
        address to,
        bytes32 key
    ) public callerIsOwner(tokenId) {
        keys[tokenId][to] = key;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
