// SPDX-License-Identifier: MIT

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity >=0.7.0 <0.9.0;

contract NFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    uint256 public cost = 1 ether;
    uint256 public maxSupply = 20;

    string baseURI;
    string public baseExtension = ".json";

    address public artist;
    uint256 public royalityFee;

    event Sale(address from, address to, uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        uint256 _royalityFee,
        address _artist
    ) ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
        royalityFee = _royalityFee;
        artist = _artist;
    }

    // Public functions
    function mint() public payable {
        uint256 supply = totalSupply();
        require(supply <= maxSupply);

        if (msg.sender != owner()) {
            require(msg.value >= cost);

            // Pay royality to artist, and remaining to deployer of contract

            uint256 royality = (msg.value * royalityFee) / 100;
            _payRoyality(royality);

            (bool success2, ) = payable(owner()).call{
                value: (msg.value - royality)
            }("");
            require(success2);
        }

        _safeMint(msg.sender, supply + 1);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        if (msg.value > 0) {
            uint256 royality = (msg.value * royalityFee) / 100;
            _payRoyality(royality);

            (bool success2, ) = payable(from).call{value: msg.value - royality}(
                ""
            );
            require(success2);

            emit Sale(from, to, msg.value);
        }

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override {
        if (msg.value > 0) {
            uint256 royality = (msg.value * royalityFee) / 100;
            _payRoyality(royality);

            (bool success2, ) = payable(from).call{value: msg.value - royality}(
                ""
            );
            require(success2);

            emit Sale(from, to, msg.value);
        }

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public payable override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        if (msg.value > 0) {
            uint256 royality = (msg.value * royalityFee) / 100;
            _payRoyality(royality);

            (bool success2, ) = payable(from).call{value: msg.value - royality}(
                ""
            );
            require(success2);

            emit Sale(from, to, msg.value);
        }

        _safeTransfer(from, to, tokenId, _data);
    }

    // Internal functions
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function _payRoyality(uint256 _royalityFee) internal {
        (bool success1, ) = payable(artist).call{value: _royalityFee}("");
        require(success1);
    }

    // Owner functions
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setRoyalityFee(uint256 _royalityFee) public onlyOwner {
        royalityFee = _royalityFee;
    }
}
