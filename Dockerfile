FROM alpine:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ARG SKALIBS_VERSION=v2.8.0.1
ARG NSSS_VERSION=v0.0.1.1
ARG EXECLINE_VERSION=v2.5.1.0
ARG S6_VERSION=v2.8.0.0
ARG S6_DNS_VERSION=v2.3.0.2
ARG S6_NETWORKING_VERSION=v2.3.0.4
ARG S6_RC_VERSION=v0.5.0.0
ARG S6_PORTABLE_VERSION=v2.2.1.3
ARG S6_LINUX_VERSION=v2.5.0.1
ARG S6_OVERLAY_VERSION=v1.22.1.0

ENV \
 HOME="/root" \
 PS1="$(whoami)@$(hostname):$(pwd)$ " \
 S6_BEHAVIOUR_IF_STAGE2_FAILS=1 \
 S6_KILL_FINISH_MAXTIME=18000

RUN echo "====== INSTALL PACKAGES ======" \
 && apk --update upgrade \
 && apk add \
   bash \
   ca-certificates \
   coreutils \
   file \
   libressl \
   logrotate \
   make \
   net-tools \
   shadow \
   tzdata \
 && apk add --virtual .build-alpine-s6 \
   build-base \
   git \
   libressl-dev \
 \
 && echo "====== CONFIGURE SYSTEM ======" \
 && mkdir -p /mnt/config /usr/src \
 && useradd -u 1000 -g users -d /mnt/config -s /sbin/nologin guardian \
 \
 && echo "====== COMPILE SKALIBS ======" \
 && cd /usr/src \
 && git clone https://github.com/skarnet/skalibs.git \
 && cd skalibs \
 && git fetch && git fetch --tags \
 && git checkout "$SKALIBS_VERSION" \
 && ./configure --enable-clock --enable-monotonic --disable-ipv6 \
 && make -j4 strip \
 && make install \
 \
 && echo "====== COMPILE NSSS ======" \
 && cd /usr/src \
 && git clone https://github.com/skarnet/nsss.git \
 && cd nsss \
 && git fetch && git fetch --tags \
 && git checkout "$NSSS_VERSION" \
 && ./configure \
 && make -j4 strip \
 && make install \
 \
 && echo "====== COMPILE EXECLINE ======" \
 && cd /usr/src \
 && git clone https://github.com/skarnet/execline.git \
 && cd execline \
 && git fetch && git fetch --tags \
 && git checkout "$EXECLINE_VERSION" \
 && ./configure --enable-nsss \
 && make -j4 strip \
 && make install \
 \
 && echo "====== COMPILE S6 ======" \
 && cd /usr/src \
 && git clone https://github.com/skarnet/s6.git \
 && cd s6 \
 && git fetch && git fetch --tags \
 && git checkout "$S6_VERSION" \
 && ./configure --enable-nsss \
 && make -j4 strip \
 && make install \
 \
 && echo "====== COMPILE S6-DNS ======" \
 && cd /usr/src \
 && git clone https://github.com/skarnet/s6-dns.git \
 && cd s6-dns \
 && git fetch && git fetch --tags \
 && git checkout "$S6_DNS_VERSION" \
 && ./configure \
 && make -j4 strip \
 && make install \
 \
 && echo "====== COMPILE S6-NETWORKING ======" \
 && cd /usr/src \
 && git clone https://github.com/skarnet/s6-networking.git \
 && cd s6-networking \
 && git fetch && git fetch --tags \
 && git checkout "$S6_NETWORKING_VERSION" \
 && ./configure --enable-nsss --enable-ssl=libressl \
 && make -j4 strip \
 && make install \
 \
 && echo "====== COMPILE S6-RC ======" \
 && cd /usr/src \
 && git clone https://github.com/skarnet/s6-rc.git \
 && cd s6-rc \
 && git fetch && git fetch --tags \
 && git checkout "$S6_RC_VERSION" \
 && ./configure \
 && make -j4 strip \
 && make install \
 \
 && echo "====== COMPILE S6-PORTABLE-UTILS ======" \
 && cd /usr/src \
 && git clone https://github.com/skarnet/s6-portable-utils.git \
 && cd s6-portable-utils \
 && git fetch && git fetch --tags \
 && git checkout "$S6_PORTABLE_VERSION" \
 && ./configure \
 && make -j4 strip \
 && make install \
 \
 && echo "====== COMPILE S6-LINUX-UTILS ======" \
 && cd /usr/src \
 && git clone https://github.com/skarnet/s6-linux-utils.git \
 && cd s6-linux-utils \
 && git fetch && git fetch --tags \
 && git checkout "$S6_LINUX_VERSION" \
 && ./configure --enable-nsss \
 && make -j4 strip \
 && make install \
 \
 && echo "====== INSTALL S6-OVERLAY ======" \
 && cd /usr/src \
 && git clone https://github.com/just-containers/s6-overlay.git \
 && cd s6-overlay/builder \
 && git fetch && git fetch --tags \
 && git checkout "$S6_OVERLAY_VERSION" \
 && egrep 'mkdir -p \$overlaydstpath/|chmod [0-9]+ \$overlaydstpath' build-latest | sed 's/$overlaydstpath/overlay-rootfs/g' > build-here \
 && bash build-here \
 && cd overlay-rootfs \
 && cp -Ran ./* / \
 \
 && echo "====== CLEANUP ======" \
 && cd /usr/src \
 && apk del --purge .build-alpine-s6 \
 && rm -rf /tmp/* /usr/src/* /var/cache/apk/*

COPY override /
ENTRYPOINT ["/init"]
