pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

// token id 從 0 開始
contract BBox is IERC721, IERC721Metadata, Ownable {
    using Address for address;
    using Strings for uint256;

    uint16 constant public MAX_SUPPLY = 10000;

    // 到當前時間段，開放購買的 token 最大數量
    uint16 private allowMintMax;

    // 當前已開盲盒的最大數量
    uint16 private openingAmount;

    uint256 public totalSupply;

    // 開盲盒路徑
    string private _baseURI;

    // 盲盒預覽圖路徑
    string private _baseMapURI;

    string override public name;

    string override public symbol;

    // 是否開放購買
    bool private purchaseStatus = false;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    // 特定 token 的第三方授權
    mapping(uint256 => address) private _tokenApprovals;

    // 特定帳戶的第三方授權
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // 記錄到當前時間段，開放購買最大數量的改變
    event modifyAllowMintMax(uint16 amount);
    // 記錄當前階段已開盲盒最大數量的改變
    event modifyOpeningAmount(uint16 amount);
    // 紀錄開放購買狀態的改變
    event modifyPurchaseStatus(bool status);

    /**
    * name: BBOX
    * symbol: BOX
    */
    constructor (string memory _name, string memory _symbol) {
        name = _name;

        symbol = _symbol;

        totalSupply = 0;
    }

    modifier nonCaller(address account) {
        require(account != msg.sender, "Cannot use your own address.");
        _;
    }

    modifier nonZeroAddress(address account) {
        require(account != address(0), "Cannot use zero address.");
        _;
    }

    modifier existToken(uint256 tokenId) {
        require(totalSupply > tokenId, "Token hasn't been minted yet.");
        _;
    }

    modifier onlyApprovedOrOwner(address spender, uint256 tokenId) {
        address owner = this.ownerOf(tokenId);
        require(
            spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender),
            "You don't have permission to manipulate it."
        );
        _;
    }

    modifier checkSupportERC721(address from, address to, uint256 tokenId, bytes memory _data) {
        _;
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer."
        );
    }

    modifier isExceedMaxSupply(uint16 amount) {
        require(totalSupply + amount < MAX_SUPPLY, "Will exceed max supply.");
        _;
    }

    /**
    * 是否開放 mint
    */
    modifier onPurchase() {
        require(purchaseStatus, "Can't purchase now.");
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }

    function tokenURI(uint256 tokenId) override external view existToken(tokenId) returns (string memory) {
        if (tokenId < openingAmount) {
            return string(abi.encodePacked(_baseURI, tokenId.toString(), ".json"));
        }
        else {
            return _baseMapURI;
        }
    }
    
    function balanceOf(address owner) override external view nonZeroAddress(owner) returns (uint256 balance) {
        return _balances[owner];
    }

    /**
    * tokenId: 0 ~ totalSupply
    */
    function ownerOf(uint256 tokenId) override external view existToken(tokenId) returns (address owner) {
        return _owners[tokenId];
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) override external {
        this.safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) override external checkSupportERC721(from, to, tokenId, data) {
        _transfer(from, to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) override external {
        _transfer(from, to, tokenId);
    }

    /**
     * 設定第三方授權
     */
    function approve(address to, uint256 tokenId) override external
        existToken(tokenId) nonZeroAddress(to) nonCaller(to) onlyApprovedOrOwner(to, tokenId)
    {
        _tokenApprovals[tokenId] = to;

        emit Approval(msg.sender, to, tokenId);
    }

    /**
     * 取得被授權的帳戶
     */
    function getApproved(uint256 tokenId) override public view existToken(tokenId) returns (address operator) {
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool _approved) override external nonZeroAddress(operator) nonCaller(operator) {
        _operatorApprovals[msg.sender][operator] = _approved;

        emit ApprovalForAll(msg.sender, operator, _approved);
    }

    function isApprovedForAll(address owner, address operator) override public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
    * 設定開放購買區間
    */
    function setAllowMintMax(uint16 amount) external onlyOwner isExceedMaxSupply(amount) {
        allowMintMax = _calculateMaxAmount(amount);
        emit modifyAllowMintMax(allowMintMax);
    }

    /**
    * 設定開放盲盒區間
    */
    function setOpeningAmount(uint16 amount) external onlyOwner isExceedMaxSupply(amount) {
        openingAmount = _calculateMaxAmount(amount);
        emit modifyOpeningAmount(openingAmount);
    }

    /**
    * 設定開放購買狀態
    */
    function setPurchaseStatus(bool status) external onlyOwner {
        require(purchaseStatus != status, "Status has been set.");

        purchaseStatus = status;

        emit modifyPurchaseStatus(status);
    }

    /**
    * 設定開啟盲盒路徑
    */
    function setBaseURI(string memory uri) external onlyOwner {
        _baseURI = uri;
    }

    /**
    * 設定未開盲盒路徑
    */
    function setBaseMapURI(string memory uri) external onlyOwner {
        _baseMapURI = uri;
    }

    function mintNFT() external onPurchase {
        _safeMint(msg.sender, 1, "");
    }

    function airdrop(address to, uint16 amount) external onlyOwner nonZeroAddress(to) {
        _safeMint(to, amount, "");
    }

    function _transfer(address from, address to, uint256 tokenId) private
        existToken(tokenId) nonZeroAddress(to) onlyApprovedOrOwner(from, tokenId)
    {
        // 取消先前對該 token 的所有第三方授權
        this.approve(address(0), tokenId);

        _owners[tokenId] = to;
        _balances[from]--;
        _balances[to]++;

        emit Transfer(from, to, tokenId);
    }

    function _mint(address to, uint16 amount) private nonZeroAddress(to) isExceedMaxSupply(amount) {
        require(totalSupply < allowMintMax, "Exceed the supply amount of current stage.");

        for (uint16 i = 0; i < amount; i++) {
            uint16 tokenId = uint16(totalSupply + i);
            _owners[tokenId] = to;

            emit Transfer(address(0), to, tokenId);
        }

        totalSupply += amount;
        _balances[to] += amount;
    }

    function _safeMint(address to, uint16 amount, bytes memory _data) internal virtual
        checkSupportERC721(address(0), to, totalSupply, _data)
    {
        _mint(to, amount);
    }

    function _calculateMaxAmount(uint16 amount) view private returns (uint16) {
        return uint16(totalSupply + amount);
    }

    /**
    * 若轉移的目標帳戶 to 為合約帳戶，檢查是否支援 ERC721
    */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}
