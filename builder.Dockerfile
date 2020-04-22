FROM clux/muslrust AS BUILDER
ARG RELEASE=/volume/target/x86_64-unknown-linux-musl/release/
ARG SS_GIT=https://github.com/shadowsocks/shadowsocks-rust
RUN git clone ${SS_GIT} /volume && \
        cargo build --release && \
        rm -rf ${RELEASE}/*.d && \
        cp ${RELEASE}/ss* /usr/local/bin && \
        strip /usr/local/bin/*
FROM alpine AS PLUGIN
ARG OBFS_GIT=https://github.com/shadowsocks/simple-obfs.git
RUN apk add \
        git \
        gcc \
        autoconf \
        make \
        libtool \
        automake \
        zlib-dev \
        openssl \
        asciidoc \
        xmlto \
        libpcre32 \
        libev-dev \
        g++ \
        linux-headers && \
        git clone ${OBFS_GIT} && \
        cd simple-obfs && \
        git submodule update --init --recursive && \
        ./autogen.sh && \
        ./configure --disable-documentation && \
        make && \
        make install && \
        strip  /usr/local/bin/* && \
        mkdir -p /usr/local/bin/sss/lib && \
        cp /usr/local/bin/obfs-server /usr/local/bin/sss/obfs && \
        cp /usr/lib/libev.so.4.0.0 /usr/local/bin/sss/lib/libev.so.4 && \
        cp /lib/ld-musl-x86_64.so.1 /usr/local/bin/sss/lib/ld-musl-x86_64.so.1
FROM busybox:musl
COPY --from=BUILDER /usr/local/bin/ssserver /usr/bin/sss
COPY --from=PLUGIN /usr/local/bin/sss /usr/bin/
ARG TZ_URL="https://github.com/F00cked/tzdata/raw/master/Alpine/zoneinfo/Asia/Shanghai"
RUN ln -sfn /usr/bin/lib /lib && \
    wget --no-check-certificate -O /etc/localtime ${TZ_URL}
#ENTRYPOINT ["init.sh"]