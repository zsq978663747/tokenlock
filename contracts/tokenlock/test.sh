#!/usr/bin/env bash

# step 1: init
. ../../scripts/init.sh
action=$1

# step 2: set your own variables
contract="tokenlock"        # contract file's and folder's base name
accountaddr="tokenlock"     # account who set the contract code to the chain
issuer="boss"               # token issuer

# step 3: bios boot and create accounts;
if [ "${action}" == '' ];then
    . ../../scripts/boot.sh

    for name in ${accountaddr} boss inita initb initc initd; do
        new_account ${name}
    done
fi

# step 4: build and deploy contract.
if [[ "${action}" == '' || "${action}" == 'deploy' ]]; then
    set -x
    #build_contract_locally ${contract}
    build_contract_docker ${contract}
    $cleos set contract  ${accountaddr} /mycts/${contract} -p ${accountaddr}
    md5 *
fi

# step 5: test
if [ "${action}" == 'test' ]; then
    set -x

    test_create(){
        $cleos push action ${accountaddr} create '["boss", "100000000.00 CVBT", "CVB Token"]' -p ${accountaddr}
        $cleos get table ${accountaddr} CVBT stat
        $cleos get currency stats ${contract} CVBT

        # follow cmds should fail
#        $cleos push action ${accountaddr} create '["boss1", "1000000.00 CVBA", "CVB Token"]' -p ${accountaddr}   # iuuser not exist
#        $cleos push action ${accountaddr} create '["boss", "1000.000000000000000 CVBBE", "CVB Token"]' -p ${accountaddr}    # 整数和小数的0个数之和不能大于18
#        $cleos push action ${accountaddr} create '["boss", "1000000.00 CVBt", "CVB Token"]' -p ${accountaddr}    # symbol error
#        $cleos push action ${accountaddr} create '["boss", "1000000.00 CVBC", "1234567890123456789012345678901"]' -p ${accountaddr}    # meme too long
#        $cleos push action ${accountaddr} create '["boss", "1000000.00", "CVB Token"]' -p ${accountaddr}
    }
    test_create


    test_issue(){
        $cleos push action ${accountaddr} issue '["inita", "100.00 CVBT", "haha"]' -p ${issuer}
        $cleos get table ${accountaddr} inita accounts
        $cleos get currency balance ${contract} inita CVBT


        # follow cmds should fail
#        $cleos push action ${accountaddr} issue '["inita", "100.0 CVBT", "haha"]' -p ${issuer}
#        $cleos push action ${accountaddr} issue '["inita", "100.000 CVBT", "haha"]' -p ${issuer}
#        $cleos push action ${accountaddr} issue '["inita", "100.00 CVB", "haha"]' -p ${issuer}
#        $cleos push action ${accountaddr} issue '["initt", "100.00 CVBT", "haha"]' -p ${issuer}

    }
    test_issue

    test_transfer(){
        $cleos push action ${accountaddr} transfer '["inita", "initb", "10.00 CVBT", "haha"]' -p inita
        $cleos get currency balance ${contract} inita CVBT
        $cleos get currency balance ${contract} initb CVBT

    }
    test_transfer

    test_issue_lock(){
        $cleos push action ${accountaddr} issuelock '["initc", "100.00 CVBT", 100, 2, "2018-08-06T5:21:0","mmmm"]' -p ${issuer}
        $cleos get table ${accountaddr} initc issues
        $cleos get table ${accountaddr} CVBT stat


        # follow cmds should fail
#        $cleos push action ${accountaddr} issuelock '["initdt", "100.00 CVBT", 3, 1, "2018-08-06T21:37:0","mmmm"]' -p ${issuer}
#        $cleos push action ${accountaddr} issuelock '["initd", "100.00 CVBt", 3, 1, "2018-08-06T21:37:0","mmmm"]' -p ${issuer}
#        $cleos push action ${accountaddr} issuelock '["initd", "100.0 CVBT", 3, 1, "2018-08-06T21:37:0","mmmm"]' -p ${issuer}
#        $cleos push action ${accountaddr} issuelock '["initd", "100.000 CVBT", 3, 1, "2018-08-06T21:37:0","mmmm"]' -p ${issuer}
#        $cleos push action ${accountaddr} issuelock '["initb", "100.00 CVBT", 30000, 1, "2018-08-06T21:37:0","mmmm"]' -p ${issuer}
#        $cleos push action ${accountaddr} issuelock '["inita", "100.00 CVBT", 3000, 10, "2018-08-06T21:37:0","mmmm"]' -p ${issuer}
#
#        $cleos push action ${accountaddr} issuelock '["initd", "100.00 CVBT", 3, 1, "2018-09-05T3:51:0","mmmm"]' -p ${issuer}
    }
    #test_issue_lock


    test_claim(){
        $cleos push action ${accountaddr} claim '["initc", "CVBT"]' -p initc
        $cleos get currency balance ${contract} initc CVBT

    }
    #test_claim


    test_burn(){
        $cleos push action ${accountaddr} issue '["boss", "1000.00 CVBT", "haha"]' -p ${issuer}
        $cleos get currency balance ${contract} boss CVBT
        $cleos push action ${accountaddr} burn '["50.00 CVBT"]' -p ${issuer}

    }
    test_burn


    set +x
fi