FROM debian:jessie

ENV BTCDIR="/srv/btc" BTCVER="0.13.2" GOSUVER="1.9"
ENV PATH="/opt/bitcoin-${BTCVER}/bin:$PATH"

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN adduser --home ${BTCDIR} --shell /bin/bash --disabled-login --gecos "bitcoin user" bitcoin && \
    mkdir ${BTCDIR}/.bitcoin

RUN gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    curl -o /usr/local/bin/gosu -fSL https://github.com/tianon/gosu/releases/download/${GOSUVER}/gosu-$(dpkg --print-architecture) && \
    curl -o /usr/local/bin/gosu.asc -fSL https://github.com/tianon/gosu/releases/download/${GOSUVER}/gosu-$(dpkg --print-architecture).asc && \
    gpg --verify /usr/local/bin/gosu.asc && \
    rm /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu

RUN curl -SL https://bitcoin.org/laanwj-releases.asc | gpg --import && \
    curl -SLO https://bitcoin.org/bin/bitcoin-core-${BTCVER}/SHA256SUMS.asc && \
    curl -SLO https://bitcoin.org/bin/bitcoin-core-${BTCVER}/bitcoin-${BTCVER}-x86_64-linux-gnu.tar.gz && \
    gpg --verify SHA256SUMS.asc && grep " bitcoin-${BTCVER}-x86_64-linux-gnu.tar.gz\$" SHA256SUMS.asc | sha256sum -c - && \
    tar -xzf bitcoin-${BTCVER}-x86_64-linux-gnu.tar.gz -C /opt && \
    rm bitcoin-${BTCVER}-x86_64-linux-gnu.tar.gz SHA256SUMS.asc

ADD docker-entrypoint.sh backup.sh restore.sh /sbin/
RUN chmod +x /sbin/docker-entrypoint.sh /sbin/backup.sh /sbin/restore.sh

WORKDIR $BTCDIR

EXPOSE 8333/tcp 8332/tcp 18333/tcp 18332/tcp
VOLUME [$BTCDIR]

ENTRYPOINT ["/sbin/docker-entrypoint.sh", "bitcoind", "-server"]
