FROM alpine:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk --update upgrade --no-cache \
 && apk add --no-cache \
  bash \
  ca-certificates coreutils \
  logrotate \
  openssl \
  shadow \
  tzdata \
 && rm -f /etc/logrotate.d/acpid

ARG S6_OVERLAY_VERSION=v3.0.0.2-2
RUN echo "====== COMPILE S6-OVERLAY ======" \
 && mkdir /usr/src \
 && apk add --no-cache --virtual .build-s6 \
  build-base \
  git \
  linux-headers \
  make \
  openssl-dev \
 && git -C /usr/src clone -b "$S6_OVERLAY_VERSION" --single-branch --depth=1 https://github.com/just-containers/s6-overlay.git && cd /usr/src/s6-overlay \
 && make rootfs-overlay-arch rootfs-overlay-noarch \
 && make symlinks-overlay-arch symlinks-overlay-noarch \
 && make syslogd-overlay-noarch \
 && cd /usr/src/s6-overlay/output/rootfs-overlay-x86_64-linux-musl && cp -Ran ./* / \
 && cd /usr/src/s6-overlay/output/rootfs-overlay-noarch && cp -Ran ./* / \
 && cd /usr/src/s6-overlay/output/symlinks-overlay-arch && cp -Ran ./* / \
 && cd /usr/src/s6-overlay/output/symlinks-overlay-noarch && cp -Ran ./* / \
 && cd /usr/src/s6-overlay/output/syslogd-overlay-noarch && cp -Ran ./* / \
 && cd /usr/src && rm -rf /usr/src/* \
 && apk del --purge .build-s6 && rm -rf /var/cache/apk/*

ENV \
 HOME="/root" \
 PS1="$(whoami)@$(hostname):$(pwd)$ " \
 S6_BEHAVIOUR_IF_STAGE2_FAILS=1 \
 S6_KILL_FINISH_MAXTIME=18000 \
 S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
 PATH=/usr/local/sbin:/usr/local/bin:/command:/usr/sbin:/usr/bin:/sbin:/bin

RUN mkdir -p /mnt/config \
 && useradd -u 1000 -g users -d /mnt/config/home -s /sbin/nologin guardian

COPY override /
ENTRYPOINT ["/init"]
