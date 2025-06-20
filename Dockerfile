# SPDX-FileCopyrightText: 2019-2025 Daniel Wolf <nephatrine@gmail.com>
# SPDX-License-Identifier: ISC

# hadolint global ignore=DL3018

FROM code.nephatrine.net/nephnet/nxb-alpine:3.21 AS builder

ARG S6_OVERLAY_VERSION=v3.2.1.0
# hadolint ignore=SC2016
RUN git -C /root clone -b "$S6_OVERLAY_VERSION" --single-branch --depth=1 https://github.com/just-containers/s6-overlay.git \
  && sed -i 's~=$(TOOLCHAIN_PATH)/bin/$(ARCH)-~=/usr/bin/$(ARCH)-~g' /root/s6-overlay/mk/bearssl.mk \
  && sed -i 's~ $(TOOLCHAIN_PATH)/bin/$(ARCH)-gcc~~g' /root/s6-overlay/mk/skaware.mk /root/s6-overlay/mk/bearssl.mk \
  && sed -i 's~ $(TOOLCHAIN_PATH)/bin:~~g' /root/s6-overlay/mk/skaware.mk /root/s6-overlay/mk/bearssl.mk \
  && sed -i 's~include mk/toolchain.mk~~g' /root/s6-overlay/Makefile
WORKDIR /root/s6-overlay

RUN echo "====== COMPILE S6-OVERLAY ======" \
  && ARCH_TRIPLET="$(uname -m)-alpine-linux-musl" \
  && if [ "$(uname -m)" = "i686" ]; then ARCH_TRIPLET="i586-alpine-linux-musl"; fi \
  && if [ "$(uname -m)" = "armv7l" ]; then ARCH_TRIPLET="armv7-alpine-linux-musleabihf"; fi \
  && if [ "$(uname -m)" = "armv8l" ]; then ARCH_TRIPLET="armv7-alpine-linux-musleabihf"; fi \
  && ln -s ar "/usr/bin/${ARCH_TRIPLET}-ar" \
  && ln -s ranlib "/usr/bin/${ARCH_TRIPLET}-ranlib" \
  && ln -s strip "/usr/bin/${ARCH_TRIPLET}-strip" \
  && make ARCH="${ARCH_TRIPLET}" rootfs-overlay-arch rootfs-overlay-noarch \
  && make ARCH="${ARCH_TRIPLET}" -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) symlinks-overlay-arch symlinks-overlay-noarch \
  && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) syslogd-overlay-noarch \
  && mv "/root/s6-overlay/output/rootfs-overlay-${ARCH_TRIPLET}" /root/s6-overlay/output/rootfs-overlay-arch

FROM alpine:3.21
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
  && apk --update upgrade --no-cache \
  && apk add --no-cache bash ca-certificates coreutils curl logrotate openssl setarch shadow tzdata \
  && rm -f /etc/logrotate.d/acpid \
  && mkdir -p /mnt/config \
  && useradd -u 1000 -g users -d /mnt/config/home -s /sbin/nologin guardian \
  && rm -rf /tmp/* /var/tmp/*

ENV HOME="/root" PS1="$(whoami)@$(hostname):$(pwd)$ " S6_BEHAVIOUR_IF_STAGE2_FAILS=1 S6_KILL_FINISH_MAXTIME=18000 S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 PATH=/usr/local/sbin:/usr/local/bin:/command:/usr/sbin:/usr/bin:/sbin:/bin
COPY --from=builder /root/s6-overlay/output/rootfs-overlay-arch/ /root/s6-overlay/output/rootfs-overlay-noarch/ /root/s6-overlay/output/symlinks-overlay-arch/ /root/s6-overlay/output/symlinks-overlay-noarch/ /root/s6-overlay/output/syslogd-overlay-noarch/ /
COPY override /

ENTRYPOINT ["/init"]
