FROM debian:unstable
MAINTAINER Nicola Busanello <sudo@inbitcoin.it>

ENV BTCDIR="/srv/btc"

RUN apt-get update && \
    apt-get install -y bitcoind gosu && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN adduser --home ${BTCDIR} --shell /bin/bash --disabled-login --gecos "bitcoin user" bitcoin && \
    mkdir ${BTCDIR}/.bitcoin

ADD docker-entrypoint.sh /sbin/
RUN chmod +x /sbin/docker-entrypoint.sh

WORKDIR $BTCDIR

EXPOSE 8333/tcp 8332/tcp 18333/tcp 18332/tcp
VOLUME [$BTCDIR]

ENTRYPOINT ["/sbin/docker-entrypoint.sh", "bitcoind", "-server"]
CMD ["-rpcuser=rpc", "-rpcpassword=rpc"]
