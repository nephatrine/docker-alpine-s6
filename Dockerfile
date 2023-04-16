FROM nephatrine/nxbuilder:alpine AS builder

ARG S6_OVERLAY_VERSION=v3.1.4.2
RUN git -C /root clone -b "$S6_OVERLAY_VERSION" --single-branch --depth=1 https://github.com/just-containers/s6-overlay.git

RUN echo "====== COMPILE S6-OVERLAY ======" \
 && cd /root/s6-overlay \
 && make rootfs-overlay-arch rootfs-overlay-noarch \
 && make symlinks-overlay-arch symlinks-overlay-noarch \
 && make syslogd-overlay-noarch

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
 && rm -f /etc/logrotate.d/acpid \
 && mkdir -p /mnt/config \
 && useradd -u 1000 -g users -d /mnt/config/home -s /sbin/nologin guardian

ENV \
 HOME="/root" \
 PS1="$(whoami)@$(hostname):$(pwd)$ " \
 S6_BEHAVIOUR_IF_STAGE2_FAILS=1 \
 S6_KILL_FINISH_MAXTIME=18000 \
 S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
 PATH=/usr/local/sbin:/usr/local/bin:/command:/usr/sbin:/usr/bin:/sbin:/bin
 
COPY --from=builder \
 /root/s6-overlay/output/rootfs-overlay-x86_64-linux-musl/ \
 /root/s6-overlay/output/rootfs-overlay-noarch/ \
 /root/s6-overlay/output/symlinks-overlay-arch/ \
 /root/s6-overlay/output/symlinks-overlay-noarch/ \
 /root/s6-overlay/output/syslogd-overlay-noarch/ /
COPY override /

ENTRYPOINT ["/init"]
