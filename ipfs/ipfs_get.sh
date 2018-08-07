#!/usr/bin/env bash

set_proxy(){
    https_proxy = http://127.0.0.1:1080/
    http_proxy = http://127.0.0.1:1080/
    ftp_proxy = http://127.0.0.1:1080/
}

unset_proxy(){
    unset https_proxy
    unset http_proxy
    unset ftp_proxy
}

IPFS_GATE_WAY=' https://ipfs.infura.io/ipfs/'
files='
QmSM9ugdN9GHjEuSk4gmiawo1syN6S6ok7hpdSJFdaxS58
Qmca5a3vCvctaNzC7hbDkda3gAD1CR6pyWAjM5S5L8kPdK
QmaBdrXhooSjajKvKNnYViMTg4kTzdJV96LAsFasuyUPZT
Qmef92Gfr5CMqnAXLytDcVfTDtbVjZvTjrjqJSsu2wAtT1
QmXLXEmLQqRL8ZMPoskH5rwwebRHKrHfz7hL6v8C7tNqWU
'

set_proxy

cd ./v1/
for f in $files; do 
    wget ${IPFS_GATE_WAY}${f}
done

unset_proxy