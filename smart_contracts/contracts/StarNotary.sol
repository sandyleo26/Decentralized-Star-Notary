pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';

contract StarNotary is ERC721 {

    struct Star {
        string name;
        string starStory;
        string ra;
        string dec;
        string mag;
    }

    // token id to star
    mapping(uint256 => Star) public tokenIdToStarInfo;
    // star to sale
    mapping(uint256 => uint256) public starsForSale;
    // star hash to true/false for uniqueness check
    mapping(bytes32 => bool) public starHashMap;


    function createStar(string _name, string _starStory, string _ra, string _dec, string _mag, uint256 _tokenId) public {
        // check token id is not 0
        require(_tokenId != 0, "_tokenId is 0");
        // check if token id already exists
        require(keccak256(abi.encodePacked(tokenIdToStarInfo[_tokenId].ra)) == keccak256(""), "_tokenId already exists");

        // check input is not empty
        require(keccak256(abi.encodePacked(_ra)) != keccak256(""), "_ra is empty");
        require(keccak256(abi.encodePacked(_dec)) != keccak256(""), "_dec is empty");
        require(keccak256(abi.encodePacked(_mag)) != keccak256(""), "_mag is empty");

        // check if coordinates exists
        require(!checkIfStarExist(_ra, _dec, _mag), "coordinate already exists");

        Star memory newStar = Star(_name, _starStory, _ra, _dec, _mag);
        tokenIdToStarInfo[_tokenId] = newStar;
        bytes32 starHash = generateStarHash(_ra, _dec, _mag);
        starHashMap[starHash] = true;

        mint(_tokenId);
    }

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(this.ownerOf(_tokenId) == msg.sender, "only owner is allowed to sell");

        starsForSale[_tokenId] = _price;
    }

    function buyStar(uint256 _tokenId) public payable {
        require(starsForSale[_tokenId] > 0, "_tokenId not exists");

        uint256 starCost = starsForSale[_tokenId];
        address starOwner = this.ownerOf(_tokenId);
        require(msg.value >= starCost, "value not enough");

        _removeTokenFrom(starOwner, _tokenId);
        _addTokenTo(msg.sender, _tokenId);

        starOwner.transfer(starCost);

        if(msg.value > starCost) {
            msg.sender.transfer(msg.value - starCost);
        }
    }

    // check star exists by given coordinates
    function checkIfStarExist(string _ra, string _dec, string _mag) public view returns(bool) {
        return starHashMap[generateStarHash(_ra, _dec, _mag)];
    }

    // generate hash for coordinates
    function generateStarHash(string _ra, string _dec, string _mag) private pure returns(bytes32) {
        return keccak256(abi.encodePacked(_ra, _dec, _mag));
    }

    // return star's cost
    function starsForSale(uint256 _tokenId) public view returns(uint256){
        return starsForSale[_tokenId];
    }

    // wrapper to mint token
    function mint(uint256 _tokenId) public {
        super._mint(msg.sender, _tokenId);
    }

    // wrapper for setApprovalForAll
    function SetApprovalForAll(address to, bool approved) public {
        super.setApprovalForAll(to, approved);
    }
}
