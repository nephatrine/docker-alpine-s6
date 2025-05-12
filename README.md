<!--
SPDX-FileCopyrightText: 2019-2025 Daniel Wolf <nephatrine@gmail.com>
SPDX-License-Identifier: ISC
-->

# Alpine S6-Overlay

[![NephCode](https://img.shields.io/static/v1?label=Git&message=NephCode&color=teal)](https://code.nephatrine.net/NephNET/docker-alpine-s6)
[![GitHub](https://img.shields.io/static/v1?label=Git&message=GitHub&color=teal)](https://github.com/nephatrine/docker-alpine-s6)
[![Registry](https://img.shields.io/static/v1?label=OCI&message=NephCode&color=blue)](https://code.nephatrine.net/NephNET/-/packages/container/alpine-s6/latest)
[![DockerHub](https://img.shields.io/static/v1?label=OCI&message=DockerHub&color=blue)](https://hub.docker.com/repository/docker/nephatrine/alpine-s6/general)
[![unRAID](https://img.shields.io/static/v1?label=unRAID&message=template&color=orange)](https://code.nephatrine.net/NephNET/unraid-containers)

This container image contains Alpine Linux with the Skarnet S6 supervisor, and
the S6 overlay installed. It is intended as a base image for other containerized
applications. It is not intended to be generally useful outside that context and
support is provided purely on a best effort basis.

This base image creates slightly chunkier base images. The images are still
relatively small and performant, but include some niceties that other containers
don't bother including like cron, logrotate, and bash. It also includes a
non-root userid which can be mapped to a userid outside the container for the
purposes of keeping permissions sane on the mounted data volume.

## Supported Tags

- `alpine-s6:3.21-3.2.1.0`: Alpine 3.21 w/ s6-overlay 3.2.1.0
- `alpine-s6:3.20-3.2.0.2`: Alpine 3.20 w/ s6-overlay 3.2.0.2
- `alpine-s6:3.19-3.1.6.2`: Alpine 3.19 w/ s6-overlay 3.1.6.2
- `alpine-s6:3.18-3.1.6.2`: Alpine 3.18 w/ s6-overlay 3.1.6.2

## Software

- [Alpine Linux](https://alpinelinux.org/)
- [Skarnet S6](https://skarnet.org/software/s6/)
- [s6-overlay](https://github.com/just-containers/s6-overlay)

## Configuration

- `TZ`: Time Zone (i.e. `America/New_York`)
- `PUID`: Mounted File Owner User ID
- `PGID`: Mounted File Owner Group ID

## Testing

### docker-compose

```yaml
services:
  alpine-s6:
    image: nephatrine/alpine-s6:latest
    container_name: alpine-s6
    environment:
      TZ: America/New_York
      PUID: 1000
      PGID: 1000
    volumes:
      - /mnt/containers/alpine-s6:/mnt/config
```

### docker run

```bash
docker run --rm -ti code.nephatrine.net/nephnet/alpine-s6:latest /bin/bash
```
