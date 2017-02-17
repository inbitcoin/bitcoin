#!/bin/sh

chown -R bitcoin .

exec gosu bitcoin $@
