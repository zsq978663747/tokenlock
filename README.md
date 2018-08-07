
#### tokenlock
Add lock and burn token function to eosio.token contract.

#### 合约功能 Contract functions
1. Fully compatible with eosio.token contracts. so you can use below commands to interact with this contract.  
   `cleos get currency stats ${contract_name} ${symbol_name}`   
   `cleos get currency balance ${contract_name} ${owner} ${symbol_name}`  
   `cleos transfer -c ${contract_name} ${from} ${to} ${asset} ${memo}`  
2. You can set the lock rules for each user, and you can set the start time of the locking issue.  
3. issuer can burn the tokens away in the issuer's balance, which will also reduce the total token supply.  

[Test Manual](https://github.com/EosTokenMarket/tokenlock/blob/master/test_manual.md)
[User Manual](https://github.com/EosTokenMarket/tokenlock/blob/master/user_manual.md)


#### 审查报告 audit report

说明：审查报告中需包含
1. 合约文件的ipfs地址，合约文件包括 *.hpp *.cpp *.wasm *.wast *.abi 
2. eos-dev镜像的 version 和 id （eosio/eos-dev作为统一编译环境） 
3. 编译命令 

Note: Audit report should includes: 
1. the ipfs addresses of the contract files. The contract files include *.hpp *.cpp *.wasm *.wast *.abi.
2. eos-dev image version and id (we use docker image eosio/eos-dev as unified compiler environment)
3. compiling commands

Audit Report:
image-url

#### 审查流程及相关说明 Audit process and related instructions
整个审核过程中，为了保证相关文件内容的确定性，合约文件均采用IPFS进行存储和获取。  
交付和审核的内容均以 ipfs 地址为准，而不是以 github repo 中的文件为准。

1. 项目方将定稿的合约文件上传到ipfs网络，并在下表中填写对应文件的ipfs地址，之后向安全团队提出审查申请。
2. 安全团队根据ipfs地址下载合约文件进行审查。
3. 若发现漏洞，安全团队和项目方协作修改文件，之后，项目方重新上传合约文件到ipfs网络，再次审核。  
4. 审核通过后，安全团队提供审核报告。  

During the entire audit process, in order to ensure the certainty of the content, the contract files are stored and acquired by IPFS protocal.
The files of delivery and audit are based on the IPFs address, not the files in GitHub repo.     
1. The project party uploads the finalized contract files to the IPFS network, fills in the IPFS address of the corresponding files in the following table, and then submits an application for audit to the security team.
2. the security team will audit the contract documents according to the IPFS address.
3. If a vulnerability is found, the security team and the project party cooperate to modify the source code. After that, the project party uploads these updated contract files to the IPFS network again, and security team audit again.
4. when the audit passed, the security team will provide the audit report.

#### 合约文件及编译环境 contract files and build environment

| version | file | ipfs address | 
| ------- | ---- | ------------ | 
| v1 | [tokenlock.hpp](https://ipfs.io/ipfs/QmaBdrXhooSjajKvKNnYViMTg4kTzdJV96LAsFasuyUPZT)  | QmaBdrXhooSjajKvKNnYViMTg4kTzdJV96LAsFasuyUPZT |
| v1 | [tokenlock.cpp](https://ipfs.io/ipfs/Qmca5a3vCvctaNzC7hbDkda3gAD1CR6pyWAjM5S5L8kPdK)  | Qmca5a3vCvctaNzC7hbDkda3gAD1CR6pyWAjM5S5L8kPdK |
| v1 | [tokenlock.wast](https://ipfs.io/ipfs/QmXLXEmLQqRL8ZMPoskH5rwwebRHKrHfz7hL6v8C7tNqWU) | QmXLXEmLQqRL8ZMPoskH5rwwebRHKrHfz7hL6v8C7tNqWU |
| v1 | [tokenlock.wasm](https://ipfs.io/ipfs/Qmef92Gfr5CMqnAXLytDcVfTDtbVjZvTjrjqJSsu2wAtT1) | Qmef92Gfr5CMqnAXLytDcVfTDtbVjZvTjrjqJSsu2wAtT1 |
| v1 | [tokenlock.abi](https://ipfs.io/ipfs/QmVQPWTZD2xvZLjU83aaWpjPtNo5fG5rbvhSeeXkkxbLTt)  | QmVQPWTZD2xvZLjU83aaWpjPtNo5fG5rbvhSeeXkkxbLTt |

``` 
version: v1
eosio-dev: version v1.1.1 , image id 8fa0988c81cc
build command:
cd contracts/tokenlock
docker run --rm -v `pwd`:/scts eosio/eos-dev:v1.1.1 bash -c "cd /scts \
    && eosiocpp -o ${contract}.wast ${contract}.cpp \
    && eosiocpp -g ${contract}.abi ${contract}.cpp"
```

Notes：  
[ipfs gateway list](https://ipfs.github.io/public-gateway-checker/)  
you can access these files through any active ipfs gateway, such as `https://ipfs.io/ipfs/<ipfs-address>`.  

#### ipfs commands
``` 
ipfs add <file name>
ipfs get <ipfs address>
```
