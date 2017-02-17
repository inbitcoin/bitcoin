#!/bin/bash

die()
{
    echo "$@"
    exit 1
}

mount |grep -q 'on /backup' || die "mount a volume/directory on /backup"
if [ -n "$1" ]; then
    BASE="$1"
else
    BASE="`date +%F`"
fi

if [ -d .bitcoin/chainstate ]; then
    tar -C /srv/btc -zcvf "/backup/${BASE}_mainnet.tar.gz" .bitcoin/{chainstate,blocks}
elif [ -d .bitcoin/testnet3/chainstate ]; then
    tar -C /srv/btc -zcvf "/backup/${BASE}_testnet.tar.gz" .bitcoin/testnet3/{chainstate,blocks}
else
    die "cannot determine if mainnet or testnet, aborting"
fi
