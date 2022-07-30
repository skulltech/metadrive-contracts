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

    // Make sure that address is registered
    modifier isRegistered(address addr) {
        require(publicKeys[addr] != 0, "Address is not registered.");
        _;
    }

    // Make sure that address is the NFT owner
    modifier isOwner(uint256 tokenId, address addr) {
        require(addr == ownerOf(tokenId), "Address does not own the file.");
        _;
    }

    // Make sure that address is not the NFT owner
    modifier isNotOwner(uint256 tokenId, address addr) {
        require(addr != ownerOf(tokenId), "Address owns the file.");
        _;
    }

    // Events
    event Mint(uint256 tokenId, address to, string uri, string fileKey);
    event Register(address addr, bytes32 publicKey);
    event Share(uint256 tokenId, address to, string fileKey);
    event Unshare(uint256 tokenId, address to);

    constructor() ERC721("MetadriveFile", "MDF") {}

    // Register an address
    function register(bytes32 publicKey) public {
        publicKeys[msg.sender] = publicKey;
        emit Register({addr: msg.sender, publicKey: publicKey});
    }

    // Mint a Metadrive File NFT
    function safeMint(string memory uri, string memory fileKey)
        public
        isRegistered(msg.sender)
    {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        fileKeys[tokenId][msg.sender] = fileKey;
        emit Mint({
            tokenId: tokenId,
            to: msg.sender,
            uri: uri,
            fileKey: fileKey
        });
    }

    // Share a file i.e. give read access to an address
    function share(
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
        emit Share({tokenId: tokenId, to: to, fileKey: fileKey});
    }

    // Unshare a file i.e. revoke read access from an user
    function unshare(uint256 tokenId, address to)
        public
        isRegistered(msg.sender)
        isRegistered(to)
        isOwner(tokenId, msg.sender)
        isNotOwner(tokenId, to)
    {
        delete fileKeys[tokenId][to];
        emit Unshare({tokenId: tokenId, to: to});
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
