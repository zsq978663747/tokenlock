
### tokenlock


### 审核说明
整个审核过程中，为了保证相关文件内容的确定性，合约文件均采用IPFS进行存储和索引。  
交付和审核的内容均已IPFS地址为准，而不是以github repo文件为准。

---
eip: 20
title: ERC-20 Token Standard
author: Fabian Vogelsteller <fabian@ethereum.org>, Vitalik Buterin <vitalik.buterin@ethereum.org>
type: Standards Track
category: ERC
status: Final
created: 2015-11-19
---



### 合约功能说明
在eosio.token合约基础上增加了锁仓和燃烧功能，可以为每一个用户单独指定锁仓规则。
具体测试案例，请参考 contract/tokenlock/test.sh

### 合约验证流程


