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

    // For each tokenized file, store the encrypted file key
    mapping(uint256 => mapping(address => string)) public fileKeys;

    // Store the public key for each registered address
    mapping(address => bytes32) public publicKeys;

    // Checks if the address is registered
    modifier isRegistered(address addr) {
        require(publicKeys[addr].length > 0, "Address is not registered.");
        _;
    }

    // Checks if the address is not registred
    modifier isNotRegistered(address addr) {
        require(publicKeys[addr].length == 0, "Address is already registered.");
        _;
    }

    // Checks if the address is the NFT owner
    modifier isOwner(uint256 tokenId, address addr) {
        require(addr == ownerOf(tokenId), "Address does not own the file.");
        _;
    }

    // Checks if the address is not the NFT owner
    modifier isNotOwner(uint256 tokenId, address addr) {
        require(addr != ownerOf(tokenId), "Address owns the file.");
        _;
    }

    constructor() ERC721("MetadriveFile", "MDF") {}

    function safeMint(string memory uri, string memory fileKey) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        // Store the encrypted file key of this file for this user
        fileKeys[tokenId][msg.sender] = fileKey;
    }

    // Register an address
    function register(bytes32 publicKey) public isNotRegistered(msg.sender) {
        publicKeys[msg.sender] = publicKey;
    }

    // Share a file i.e. give read access to an address
    function shareFile(
        uint256 tokenId,
        address to,
        string memory fileKey
    )
        public
        isRegistered(msg.sender)
        isRegistered(to)
        isOwner(tokenId, msg.sender)
    {
        fileKeys[tokenId][to] = fileKey;
    }

    // Unshare a file i.e. revoke read access from an user
    function unshareFile(uint256 tokenId, address to)
        public
        isRegistered(msg.sender)
        isRegistered(to)
        isOwner(tokenId, msg.sender)
        isNotOwner(tokenId, to)
    {
        delete fileKeys[tokenId][to];
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
