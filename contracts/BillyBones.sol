// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract BillyBones {
    string private uri;
    address private contractOwner;
    uint256 private tokenIdCounter = 0;
    uint256 public PRICE = 0.001 ether;
    uint256 public MAX_SUPPLY = 100;

    constructor(string memory _uri) {
        contractOwner = msg.sender;
        uri = _uri;
    }

    // ERC721 --------------------------------------------------------------->>
    mapping(uint256 => address) private ownership;
    mapping(uint256 => address) private approvedForToken;
    mapping(address => mapping(address => bool)) private approvedForAll;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function ownerOf(uint256 _tokenId) public view virtual returns (address) {
        return ownership[_tokenId];
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public {
        require(msg.sender == ownership[_tokenId] || msg.sender == getApproved(_tokenId) || isApprovedForAll(ownership[_tokenId], msg.sender), "Unauthorized");
        require(ownership[_tokenId] == _from, "The from address does not own this token"); 

        // Clear approvals from the previous owner
        approvedForToken[_tokenId] = address(0);
        emit Approval(ownership[_tokenId], address(0), _tokenId);

        ownership[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function approve(address _candidate, uint256 _tokenId) public virtual {
        require(msg.sender == ownership[_tokenId] || isApprovedForAll(ownership[_tokenId], msg.sender), "Unauthorized");
        approvedForToken[_tokenId] = _candidate;
        emit Approval(ownership[_tokenId], _candidate, _tokenId);
    }

    function getApproved(uint256 _tokenId) public view virtual returns (address) {
        return approvedForToken[_tokenId];
    }

    function setApprovalForAll(address _candidate, bool _approved) public virtual {
        approvedForAll[msg.sender][_candidate] = _approved;
        emit ApprovalForAll(msg.sender, _candidate, _approved);
    }

    function isApprovedForAll(address _owner, address _candidate) public view virtual returns (bool) {
        return approvedForAll[_owner][_candidate];
    }

    // UNSAFE - USE AT OWN RISK
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public { transferFrom(_from, _to, _tokenId); }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) public { transferFrom(_from, _to, _tokenId); }
    
    // Ignored
    function balanceOf(address _owner) public view virtual returns (uint256) { return 0; }
    // <<--------------------------------------------------------------- ERC721


    // ERC721Metadata ------------------------------------------------------->>
    function name() public view virtual returns (string memory) {
        return "B I L L Y B O N E S";
    }

    function symbol() public view virtual returns (string memory) {
        return ">---< >--< >---<";
    }

    function tokenURI(uint256 _tokenId) public view virtual returns (string memory) {
        return uri; // Everyone gets the same URI
    }
    // <<------------------------------------------------------- ERC721Metadata


    // ERC165 --------------------------------------------------------------->>
    function supportsInterface(bytes4 _interfaceId) public pure returns (bool) {
        return _interfaceId == 0x80ac58cd || // IERC721
            _interfaceId == 0x5b5e139f || // IERC721Metadata
            _interfaceId == 0x01ffc9a7; // IERC165
    }
    // <<--------------------------------------------------------------- ERC165


    // Ownable -------------------------------------------------------------->>
    function owner() public view virtual returns (address) {
        return contractOwner;
    }
    // <<-------------------------------------------------------------- Ownable


    // ERC721TokenReceiver -------------------------------------------------->>
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) public pure returns(bytes4) {
        revert("Sorry, I can't receive NFTs");
    }
    // <<-------------------------------------------------- ERC721TokenReceiver


    // Other functions ------------------------------------------------------>>
    function setUri(string memory _uri) public {
        require(msg.sender == contractOwner);
        uri = _uri;
    }

    // UNSAFE - USE AT OWN RISK
    function mint() public payable {
        tokenIdCounter++;
        require(tokenIdCounter <= MAX_SUPPLY, "Sold out");
        require(msg.value >= PRICE, "Send more ETH");
        
        // Whisk the money off to the contractOwner right away
        (bool success, ) = payable(contractOwner).call{value: msg.value}("");
        require(success, "Could not transfer money to contractOwner");

        ownership[tokenIdCounter] = msg.sender;
        emit Transfer(address(0), msg.sender, tokenIdCounter);
    }

    // Required by etherscan.io
    function totalSupply() public view virtual returns (uint256) {
        return MAX_SUPPLY;
    }
    // <<----------------------------------------------------- Other functions
}
