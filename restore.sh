#!/bin/bash

die()
{
    echo "$@"
    exit 1
}

[ -n "$1" ] || die "provide a link to the .tar.gz backup file"

curl "$1" | tar -C /srv/btc -zxv
