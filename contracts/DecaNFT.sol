// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
pragma abicoder v2;

import "@layerzerolabs/solidity-examples/contracts/token/onft721/ONFT721.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

error ReachedMaxTotalSupply();
error ReachedMaxTreasurySupply();
error InvalidMinter(address minter);
error MintNotAvailable();
error MintLimitExceeded();

contract DecaNFT is ONFT721, ERC2981 {
    using Strings for uint256;

    string public baseTokenURI;
    string public prerevealTokenURI;

    bool public revealed;
    bool public whiteListingPeriod;
    bool public mintState;

    uint256 public mintLimit;
    uint256 public totalSupply;
    uint256 public constant MAX_ELEMENTS = 2024;
    uint256 public treasuryMintedCount = 0;
    uint256 private constant MAX_TREASURY_MINT_LIMIT = 100;

    address public treasuryAddress;

    // Permitted cashier minters
    mapping(address => bool) public minters;

    constructor(string memory baseURI, string memory _name, string memory _symbol, uint256 _minGasToTransfer, address _lzEndpoint) ONFT721(_name, _symbol, _minGasToTransfer, _lzEndpoint) {
        setBaseURI(baseURI);
    }

    event TreasuryMint(
        address indexed recipient,
        uint256 quantity,
        uint256 fromIndex
    );

    event MintStateChanged(
        bool state
    );

    //Base URI for all tokens
    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _exists(tokenId);

        if (revealed == false) {
            return prerevealTokenURI;
        }
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, "/", tokenId.toString())) : "";
    }

    // Pre-revealing image URI for all NFTs
    function setPrerevealTokenURI(string memory prerevealURI) public onlyOwner {
        prerevealTokenURI = prerevealURI;
    }

    // Toggle for showing default Image or individual images.
    function setRevealed(bool _revealed) public onlyOwner {
        revealed = _revealed;
    }

    // Set limit for NFT batch minting
    function setMintLimit(uint256 _mintLimit) external onlyOwner {
        mintLimit = _mintLimit;
    }

    // Set NFT mint availability
    function setMintState(bool _mintState) external onlyOwner {
        mintState = _mintState;
        emit MintStateChanged(mintState);
    }
    
    //Setting WhiteListing Round
    function enableWhiteListing(bool _whiteListingPeriod) external onlyOwner {
        whiteListingPeriod = _whiteListingPeriod;
    }

    //Adding to whitelist    
    function addToWhiteList(address minterAddress) external onlyOwner {
        minters[minterAddress] = true;
    }

    //Removing from whitelist
    function removeFromWhiteList(address minterAddress) external onlyOwner {
        delete minters[minterAddress];
    }

    modifier checkMintAvailability(address _addr) {
        if (mintState == false) {
            revert MintNotAvailable();
        }
        if (totalSupply >= MAX_ELEMENTS) {
            revert ReachedMaxTotalSupply();
        }
        if (mintLimit != 0 && balanceOf(_addr) >= mintLimit) {
            revert MintLimitExceeded();
        }
        if (whiteListingPeriod && !minters[_addr]) {
            revert InvalidMinter(_addr);
        }
        _;
    }

    // function mint(uint256 id) external checkMintAvailability(msg.sender) {
    //     _safeMint(_msgSender(), id);
    //     totalSupply++;
    // }
    function mint(address _addr, uint id)  external payable {
        _safeMint(_addr, id);
        totalSupply++;
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId);
    }
    
    // Set address for treasury wallet
    function setTreasuryAddress(address _treasuryAddress) external onlyOwner {
        treasuryAddress = _treasuryAddress;
    }
    // Mint certain number of NFTs to a treasury wallet
    function treasuryMint(uint256 id) external onlyOwner {
        require(treasuryAddress != address(0), 'Treasury Address should be set up.');
        
        if (treasuryMintedCount >= MAX_TREASURY_MINT_LIMIT)
            revert ReachedMaxTreasurySupply();

        _safeMint(treasuryAddress, id);
        totalSupply++;
        treasuryMintedCount++;
    }

    // ERC2981 Royalty START
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ONFT721, ERC2981) returns (bool) {
        // Supports the following `interfaceId`s:
        // - IERC165: 0x01ffc9a7
        // - IERC721: 0x80ac58cd
        // - IERC721Metadata: 0x5b5e139f
        // - IERC2981: 0x2a55205a
        return
        ERC721.supportsInterface(interfaceId) ||
        ERC2981.supportsInterface(interfaceId);
    }

    //Sets default royalty percent and address
    function setDefaultRoyalty(
        address receiver,
        uint96 feeNumerator
    ) public onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }
    // ERC2981 Royalty END

    //Extracts token ids owned by certain address
    function walletOfOwner(address _owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);
        uint256[] memory tokensId = new uint256[](tokenCount);

        if(tokenCount == 0){
            return tokensId;
        }

        uint256 key = 0;
        for (uint256 i = 0; i < MAX_ELEMENTS; i++) {
            if(ownerOf(i) == _owner){
                tokensId[key] = i;
                key++;
                if(key == tokenCount){break;}
            }
        }

        return tokensId;
    }
}