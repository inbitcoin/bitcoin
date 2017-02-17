#!/bin/sh

OPTIONS=""
[ -n "$BITCOIND_RPC_USER" ] && OPTIONS="$OPTIONS -rpcuser=$BITCOIND_RPC_USER"
[ -n "$BITCOIND_RPC_PASS" ] && OPTIONS="$OPTIONS -rpcpassword=$BITCOIND_RPC_PASS"

chown -R bitcoin .

exec gosu bitcoin $@ $OPTIONS
