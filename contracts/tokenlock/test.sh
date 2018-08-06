#!/usr/bin/env bash

. ../../scripts/init.sh
action=$1

## variables
contract_name="tokenlock"
account_name="tokenlock"
issuer_name="boss"


if [ "${action}" == '' ];then
    ## step 1: bios boot.
    . ../../scripts/boot.sh

    ## step 2: create account
    key1='5J4WkksPLoraSdf38773PRYFK8K85whAyxFPLC4VgZWJf9CM1UH|EOS8U45mWyvjKmjefEWirySNyWAGKjeCXzgi9zCig3r95jRY8ads2'
    key2='5JLV5992aThqyApfDUndZdSxM49eiCGQDnBciEj4HWjMGdS1nY6|EOS593G1nBxK7qzhxUHe1KMDaJ5NhWGW9D2JPpqruftZCqPytx8pg'
    key3='5K2ocxeNE5bsQU7SH5TXNknyM61MiyE9M76nM3zkAqR4fGB4iD2|EOS8atB2B199FSNsBK6RUCVhZs1uDcaHuZYscFKbYF1yoemwb71RB'
    key4='5JY6P5oUTVD2G3ga2rHb5T5qR23DF1MfvkEE1QFFs2KGRickMf5|EOS78a3NJ7Ew9Guvf3gvv4bdU7U3FBBTeZ34maHmrESpz8KgX4fpx'
    key5='5KEiiCdgVbjj48SC2EM2yLcLBkPXvGRawvaXtWahy4VtPdu82iG|EOS83vhHzZZLzGBLREuY6TgT6sfKcTVWyGYWxhQQSsBFgTEzNQ3tb'
    key6='5JCVwpgiBfrcw8ALqKSLA3ruaWFzoSmubXzRhsTLPBvB9btGCBk|EOS8Bi2iAZFSeDPYmB3j3agrBWeFzvSRJywuNtssHXELFEchBfEjB'
    create_account_and_import_key ${account_name} ${key1}
    create_account_and_import_key boss ${key2}
    create_account_and_import_key inita ${key3}
    create_account_and_import_key initb ${key4}
    create_account_and_import_key initc ${key5}
    create_account_and_import_key initd ${key6}

fi


if [[ "${action}" == '' || "${action}" == 'deploy' ]]; then
    ## setp 3: build and deploy contract.
    build_deploy_contract(){
        cd ${ROOT_DIR}/contracts/${contract_name}
        eosiocpp -o ${contract_name}.wast ${contract_name}.cpp
        eosiocpp -g ${contract_name}.abi  ${contract_name}.cpp
#        add_abi_types ${contract_name}.abi
        cd -

        $cleos set contract  ${account_name} /mycts/${contract_name} -p ${account_name}
    }
    build_deploy_contract
fi

if [ "${action}" == 'test' ]; then
    set -x
    test_create(){
        $cleos push action ${account_name} create '["boss", "100000000.00 CVBT", "CVB Token"]' -p ${account_name}
        $cleos get table ${account_name} CVBT stat
        $cleos get currency stats ${contract_name} CVBT


        # follow cmds should fail
#        $cleos push action ${account_name} create '["boss1", "1000000.00 CVBA", "CVB Token"]' -p ${account_name}   # iuuser not exist
#        $cleos push action ${account_name} create '["boss", "1000.000000000000000 CVBBE", "CVB Token"]' -p ${account_name}    # 整数和小数的0个数之和不能大于18
#        $cleos push action ${account_name} create '["boss", "1000000.00 CVBt", "CVB Token"]' -p ${account_name}    # symbol error
#        $cleos push action ${account_name} create '["boss", "1000000.00 CVBC", "1234567890123456789012345678901"]' -p ${account_name}    # meme too long
#        $cleos push action ${account_name} create '["boss", "1000000.00", "CVB Token"]' -p ${account_name}
    }
    test_create

    test_issue(){
        $cleos push action ${account_name} issue '["inita", "100.00 CVBT", "haha"]' -p ${issuer_name}
        $cleos get table ${account_name} inita accounts
        $cleos get currency balance ${contract_name} inita CVBT


        # follow cmds should fail
#        $cleos push action ${account_name} issue '["inita", "100.0 CVBT", "haha"]' -p ${issuer_name}
#        $cleos push action ${account_name} issue '["inita", "100.000 CVBT", "haha"]' -p ${issuer_name}
#        $cleos push action ${account_name} issue '["inita", "100.00 CVB", "haha"]' -p ${issuer_name}
#        $cleos push action ${account_name} issue '["initt", "100.00 CVBT", "haha"]' -p ${issuer_name}

    }
    test_issue

    test_transfer(){
        $cleos push action ${account_name} transfer '["inita", "initb", "10.00 CVBT", "haha"]' -p inita
        $cleos get currency balance ${contract_name} inita CVBT
        $cleos get currency balance ${contract_name} initb CVBT

    }
    test_transfer

    test_issue_lock(){
        $cleos push action ${account_name} issuelock '["initc", "100.00 CVBT", 100, 2, "2018-08-06T5:21:0","mmmm"]' -p ${issuer_name}
        $cleos get table ${account_name} initc issues
        $cleos get table ${account_name} CVBT stat


        # follow cmds should fail
#        $cleos push action ${account_name} issuelock '["initdt", "100.00 CVBT", 3, 1, "2018-08-06T21:37:0","mmmm"]' -p ${issuer_name}
#        $cleos push action ${account_name} issuelock '["initd", "100.00 CVBt", 3, 1, "2018-08-06T21:37:0","mmmm"]' -p ${issuer_name}
#        $cleos push action ${account_name} issuelock '["initd", "100.0 CVBT", 3, 1, "2018-08-06T21:37:0","mmmm"]' -p ${issuer_name}
#        $cleos push action ${account_name} issuelock '["initd", "100.000 CVBT", 3, 1, "2018-08-06T21:37:0","mmmm"]' -p ${issuer_name}
#        $cleos push action ${account_name} issuelock '["initb", "100.00 CVBT", 30000, 1, "2018-08-06T21:37:0","mmmm"]' -p ${issuer_name}
#        $cleos push action ${account_name} issuelock '["inita", "100.00 CVBT", 3000, 10, "2018-08-06T21:37:0","mmmm"]' -p ${issuer_name}
#
#        $cleos push action ${account_name} issuelock '["initd", "100.00 CVBT", 3, 1, "2018-09-05T3:51:0","mmmm"]' -p ${issuer_name}
    }
    #test_issue_lock


    test_claim(){
        $cleos push action ${account_name} claim '["initc", "CVBT"]' -p initc
        $cleos get currency balance ${contract_name} initc CVBT

    }
    #test_claim


    test_burn(){
        $cleos push action ${account_name} issue '["boss", "1000.00 CVBT", "haha"]' -p ${issuer_name}
        $cleos get currency balance ${contract_name} boss CVBT
        $cleos push action ${account_name} burn '["50.00 CVBT"]' -p ${issuer_name}

    }
    test_burn

    set +x
fi