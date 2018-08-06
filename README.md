

常量

变量


## 代币状态表（stat）
``` 
    struct currency_stats {
        asset          supply;
        asset          max_supply;
        account_name   issuer;
        string         name;
        uint64_t primary_key()const { return supply.symbol.name(); }
    };
```

## 余额表（accounts）
``` 
    struct account {
        asset    balance;
        uint64_t primary_key()const { return balance.symbol.name(); }
    };
```

## 发行表（issuelock）
``` 
 - 账户名 总额度 次数 间隔 确认 确认时间 - 
    struct issuelock {
        asset   quantity;
        unint   times;
        time    duration;
        time    start_time;
        uint64_t primary_key()const { return balance.symbol.name(); }
    };

```


## 函数
``` 
public:
    void create( account_name issuer, asset maximum_supply);
    void issue( account_name to, asset quantity, string memo );
    void issuelock()
    void claim()
    void account()
    void transfer( account_name from, account_name to, asset quantity, string memo );
                  

    inline asset get_supply( symbol_name sym )const;
    inline asset get_balance( account_name owner, symbol_name sym )const;        
       
private:


```


