
### tokenlock
一个基于eosio.token，并增加锁仓和燃烧功能的代币合约。


### 合约安全审查结果
说明：审查结果中需包含
1. 合约文件的ipfs地址，合约文件包括 *.hpp *.cpp *.wasm *.wast *.abi
2. eos-dev镜像的版本号和image id （eos-dev作为统一编译环境）
3. 编译命令

<审核结果>


### 审查流程及相关说明
整个审核过程中，为了保证相关文件内容的确定性，合约文件均采用IPFS进行存储和获取。  
交付和审核的内容均以 ipfs 地址为准，而不是以 github repo 中的文件为准。

1. 项目方将定稿的合约文件上传到ipfs网络，并在下表中填写对应文件的ipfs地址，之后向安全团队提出审查申请。
2. 安全团队根据ipfs地址下载合约文件进行审查。
3. 若发现漏洞，安全团队和项目方协作修改文件，之后，项目方重新上传合约文件到ipfs网络，再次审核。
4. 审核通过后，安全团队提供审核报告。


### 合约文件及编译环境

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

相关说明：  
[ipfs gateway list](https://ipfs.github.io/public-gateway-checker/)  
你可以通过任何一个活跃的网关，如 `https://ipfs.io/ipfs/<ipfs-address>` 访问文件.   

### ipfs 常用命令
``` 
ipfs add <file name>
ipfs get <ipfs address>
```
