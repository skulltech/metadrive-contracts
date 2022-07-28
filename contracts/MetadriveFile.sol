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

    struct User {
        string username;
        bytes32 publicKey;
    }

    // For each tokenized file, store the encrypted symmetric key
    mapping(uint256 => mapping(address => string)) public encryptionKeys;

    // Store the user info for each registered address
    mapping(address => User) public users;

    // Checks if the address is the NFT owner
    modifier isOwner(uint256 tokenId, address addr) {
        require(addr == ownerOf(tokenId), "User does not own the file.");
        _;
    }

    // Checks if the address is not the NFT owner
    modifier isNotOwner(uint256 tokenId, address addr) {
        require(addr != ownerOf(tokenId), "User owns the file.");
        _;
    }

    // Checks if the address is an user
    modifier isUser(address addr) {
        require(users[addr].publicKey != 0, "User does not exist.");
        _;
    }

    // Checks if the address is not an user
    modifier isNotUser(address addr) {
        require(users[addr].publicKey == 0, "User already exists.");
        _;
    }

    constructor() ERC721("MetadriveFile", "MDF") {}

    function safeMint(string memory uri, string memory encryptionKey) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        // Store the encryptionKey of this file for this user
        encryptionKeys[tokenId][msg.sender] = encryptionKey;
    }

    // Create a new user
    function createUser(string memory username, bytes32 publicKey)
        public
        isNotUser(msg.sender)
    {
        User memory user = User({username: username, publicKey: publicKey});
        users[msg.sender] = user;
    }

    // Share a file i.e. give read access to an user
    function shareFile(
        uint256 tokenId,
        address to,
        string memory encryptionKey
    ) public isUser(msg.sender) isUser(to) isOwner(tokenId, msg.sender) {
        encryptionKeys[tokenId][to] = encryptionKey;
    }

    // Unshare a file i.e. revoke read access from an user
    function unshareFile(uint256 tokenId, address to)
        public
        isUser(msg.sender)
        isUser(to)
        isOwner(tokenId, msg.sender)
        isNotOwner(tokenId, to)
    {
        delete encryptionKeys[tokenId][to];
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
