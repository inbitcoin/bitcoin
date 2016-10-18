FROM debian:experimental
MAINTAINER Nicola Busanello <sudo@inbitcoin.it>

ENV BTCDIR="/srv/bitcoin"

RUN apt-get update && \
    apt-get install -y bitcoind/experimental && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN adduser --home ${BTCDIR} --shell /bin/bash --disabled-login --gecos "bitcoin user" bitcoin && \
	mkdir ${BTCDIR}/.bitcoin
COPY bitcoin.conf ${BTCDIR}/.bitcoin/

USER bitcoin
WORKDIR ${BTCDIR}
CMD ["bitcoind", "-server", "-rpcallowip=10.0.0.0/8", "-rpcallowip=172.16.0.0/12", "-rpcallowip=192.168.0.0/16", "-txindex", "-testnet"]
