<!--
SPDX-FileCopyrightText: 2019 - 2023 Daniel Wolf <nephatrine@gmail.com>

SPDX-License-Identifier: ISC
-->

[Git](https://code.nephatrine.net/NephNET/docker-alpine-s6/src/branch/master) |
[Docker](https://hub.docker.com/r/nephatrine/alpine-s6/) |
[unRAID](https://code.nephatrine.net/NephNET/unraid-containers)

# Alpine S6-Overlay Base Image

This docker base image contains Alpine Linux with the Skarnet S6 supervisor,
and the S6 overlay installed. It has no function on its own and is intended
to be used as a base for other docker images.

The `latest` tag points to `alpine:latest` and s6-overlay `3.1.6.2`. This is
the only image actively being updated. There are tags for older versions, but
these may no longer be using the latest Alpine version and packages.

## Docker-Compose

This is an example docker-compose file:

```yaml
services:
  alpine:
    image: nephatrine/alpine-s6:latest
    container_name: act_runner
    environment:
      TZ: America/New_York
      PUID: 1000
      PGID: 1000
    volumes:
      - /mnt/containers/alpine:/mnt/config
```

## Basic Gist

This base image creates slightly chunkier base images. The images are still
really small and performant, but include some niceties that other containers
don't bother including like cron, logrotate, and bash. It also includes a
non-root userid which can be mapped to a userid outside the container for the
purposes of keeping permissions sane on the mounted data volume.
