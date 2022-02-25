pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract BBox {
    string show;

    constructor () {
        show = "DM";
    }

    function hello() public view returns (string memory){
        return show;
    }
}
