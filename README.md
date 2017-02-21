dockerized bitcoind
===================

docker image that runs a bitcoin node


requirements
------------

* docker
* storage:
 * mainnet: 150 GB (250+ recommended) for a full node or 10 GB for a pruned node
 * testnet: 20 GB for a full node or 5 GB for a pruned node
* memory:
 * mainnet: 2 GB ram (4 recommended)
 * testnet: 1 GB ram (2 recommended)


quick start
-----------

1. create a docker volume to persist data

        # docker volume create --name=btcmain

2. [optional] restore a pre-mined (a backup) blockchain to avoid re-downloading and re-verifying everything

3. run container mounting the volume on /srv/btc optionally specifying custom options

        # docker run --name mainnet -d -v btcmain:/srv/btc -p 8333:8333 bitcoind -prune=666 -onlynet=ipv4


cleanup
-------

1. stop the running container

        # docker stop mainnet

2. remove the container along with the associated volumes

        # docker rm -v mainnet
        # docker volume rm btcmain

3. [optional] ask docker to prune the system; it might delete important stuff, make sure you understand what this does and do at your own risk

        # docker system df


backup and restore
------------------

backup:

1. have a running node with an up-to-date blockchain copy, see quick start section

2. create a backup copy of the synced blockchain as a gzip-compress tar archive; you need to mount the data volume (preferably read-only) plus some storage on /backup (to store the backup), specify `backup.sh` as entrypoint and optionally provide a name for the backup (otherwise the current date will be used); the chain name (mainnet or testnet) plus the `.tar.gz` suffix will be automatically appended

        # docker run --rm -it -v btcmain:/srv/btc:ro -v $(pwd):/backup --entrypoint backup.sh bitcoind

restore:

1. create a docker volume

        # docker volume create --name=btcmain

2. restore the desired backup copy to the newly created volume; you need to specify an http link where to get the backup from and `restore.sh` as entrypoint, the backup will be downloaded from the provided link, uncompressed and unpacked on-the-fly

        # docker run --rm -it -v btcmain:/srv/btc --entrypoint restore.sh bitcoind "https://your.sour.ce/2009-01-03_mainnet.tar.gz"


environment variables
---------------------

environment variables can be set to tweak some aspects of the bitcoin daemon

* `BITCOIN_RPC_USER` sets the username for rpc calls
* `BITCOIN_RPC_PASS` sets the password for rpc calls

one important use case is to specify credentials in a protected file on the host machine and have docker pass it on to the container as environment with the --env-file options or via docker-compose


additional info
---------------

* after restoring a backup copy of the blockchain you will need to execute the bitcoin daemon with some options set the same as the container used to create the backup copy you're restoring from, as the resulting blockchain on disk results in incompatible versions; example options that produce incompatible blockchains are -prune and -txindex

* when restoring you can serve local files with a temporary webserver (use the LAN ip and avoid localhost as the container has its own private localhost which doesn't match the host one)

        $ cd /path/where/the/backup/lies
        $ python -m SimpleHTTPServer
        # docker run --rm -it -v btcmain:/srv/btc --entrypoint /sbin/restore.sh bitcoind "http://192.168.0.1:8000/btcmain_2009-01-03.tar.gz"

* you can execute rpc calls if you launch the container with command options or environment variables to set rpc user and password (e.g. -rpcuser=rpc -rpcpassword=rpc) and then executing commands directly inside the container; this works even if the rpc port is not exposed

        # docker exec mainnet --entrypoint bitcoin-cli bitcoind -rpcuser=rpc -rpcpassword=rpc getblockchaininfo

* options you might be interested in:
 * `-prune=666` to create a pruned node to a minimum of 550 (MB) (incompatible with `-txindex`)
 * `-onlynet=ipv4` to only use ipv4 (as sometimes ipv6 support may render connections harder then needed)
 * `-connect=192.168.0.1` if as an example you already have another node exposed at 192.168.0.1 and want to use that as peer
 * `-txindex` to enable transaction indexing (useful e.g. for a block explorer)
 * `-testnet` to create a testnet node
 * `-regtest` to create a regtest node
 * `-printtoconsole` to print verbose output to console (useful e.g. in combination with `docker logs -f $CONTAINER`)
