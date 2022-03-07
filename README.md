# NFT - Blind Box (BBOX)

- 這是一個使用 ERC721 實作，並採用盲盒玩法的 NFT

---

## hardhat

- [network 設定](https://hardhat.org/config/#networks-configuration)

- [部署](https://hardhat.org/guides/deploying.html)

- 驗證合約

  ```console
  $ npx hardhat verify --network <network in hardhat.config.js> <contract account address> {construct parameters}

  // Example
  $ npx hardhat verify --network rinkeby 0X... BBOX BOX
  ```

  - References
    - https://moralis.io/how-to-verify-a-smart-contract-with-hardhat/
    - https://hardhat.org/plugins/nomiclabs-hardhat-etherscan.html
    - https://www.bnbchain.world/en/blog/verify-with-hardhat/

- 測試合約

  - @openzeppelin/test-helpers

- 運行指令範例

  ```console
  // 編譯合約
  $ npx hardhat compile

  // 運行測試
  $ npx hardhat test

  // 開啟本地測試鏈
  $ npx hardhat node

  // 部署到特定網路上
  $ npx hardhat run --network <network in hardhat.config.js> scripts/deploy.js
  ```

- [範例大全](https://betterprogramming.pub/the-complete-hands-on-hardhat-tutorial-9e23728fc8a4)

---

## IPFS (InterPlanetary File System)

- [介紹](https://blockcast.it/2019/10/16/let-me-tell-you-what-is-ipfs/)

- [如何透過 http 路徑，取得 IPFS 上的檔案](https://nft.storage/docs/how-to/retrieve/)

- 提供 IPFS 的服務商
  - https://nft.storage
  - https://www.pinata.cloud
  - https://infura.io

---

## Rinkeby 水龍頭

- https://faucet.rinkeby.io/
- https://faucets.chain.link/rinkeby

---

## Metadata

- [Opensea 支援的其他 metadata](https://docs.opensea.io/docs/metadata-standards)
-
