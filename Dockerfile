FROM nephatrine/nxbuilder:alpine AS builder

ARG S6_OVERLAY_VERSION=v3.1.5.0
RUN git -C /root clone -b "$S6_OVERLAY_VERSION" --single-branch --depth=1 https://github.com/just-containers/s6-overlay.git

RUN echo "====== COMPILE S6-OVERLAY ======" \
 && export ARCH_TRIPLET="$(uname -m)-alpine-linux-musl" \
 && if [ "$(uname -m)" = "armv7l" ]; then export ARCH_TRIPLET="armv7-alpine-linux-musleabihf"; fi \
 && ln -s ar /usr/bin/${ARCH_TRIPLET}-ar \
 && ln -s ranlib /usr/bin/${ARCH_TRIPLET}-ranlib \
 && ln -s strip /usr/bin/${ARCH_TRIPLET}-strip \
 && cd /root/s6-overlay \
 && sed -i 's~=$(TOOLCHAIN_PATH)/bin/$(ARCH)-~=/usr/bin/$(ARCH)-~g' mk/bearssl.mk \
 && sed -i 's~ $(TOOLCHAIN_PATH)/bin/$(ARCH)-gcc~~g' mk/skaware.mk mk/bearssl.mk \
 && sed -i 's~ $(TOOLCHAIN_PATH)/bin:~~g' mk/skaware.mk mk/bearssl.mk \
 && sed -i 's~include mk/toolchain.mk~~g' Makefile \
 && make ARCH=${ARCH_TRIPLET} rootfs-overlay-arch rootfs-overlay-noarch \
 && make ARCH=${ARCH_TRIPLET} -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) symlinks-overlay-arch symlinks-overlay-noarch \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) syslogd-overlay-noarch \
 && mv /root/s6-overlay/output/rootfs-overlay-${ARCH_TRIPLET} /root/s6-overlay/output/rootfs-overlay-arch

FROM alpine:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk --update upgrade --no-cache \
 && apk add --no-cache \
  bash ca-certificates coreutils logrotate openssl shadow tzdata \
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
 /root/s6-overlay/output/rootfs-overlay-arch/ \
 /root/s6-overlay/output/rootfs-overlay-noarch/ \
 /root/s6-overlay/output/symlinks-overlay-arch/ \
 /root/s6-overlay/output/symlinks-overlay-noarch/ \
 /root/s6-overlay/output/syslogd-overlay-noarch/ /
COPY override /

ENTRYPOINT ["/init"]
