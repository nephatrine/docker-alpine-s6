[Git](https://code.nephatrine.net/nephatrine/docker-alpine-s6) |
[Docker](https://hub.docker.com/r/nephatrine/alpine-s6/) |
[unRAID](https://code.nephatrine.net/nephatrine/unraid-containers)

[![Build Status](https://ci.nephatrine.net/api/badges/nephatrine/docker-alpine-s6/status.svg?ref=refs/heads/master)](https://ci.nephatrine.net/nephatrine/docker-alpine-s6)

# Alpine, S6, & S6-Overlay (Base)

This docker base image contains Alpine Linux with the Skarnet S6 supervisor,
and the S6 overlay installed. It has no function on its own and is intended
to be used as a base for other docker images.

- [Alpine Linux](https://alpinelinux.org/)
- [Skarnet Software](https://skarnet.org/software/)
- [S6 Overlay](https://github.com/just-containers/s6-overlay)

You can spin up a quick temporary test container like this:

~~~
docker run --rm -it nephatrine/alpine-s6:latest /bin/bash
~~~

## Docker Tags

- **nephatrine/alpine-s6:testing**: Alpine 3.13 (*Until UnRAID Works With Edge*)
- **nephatrine/alpine-s6:latest**: Alpine 3.13
- **nephatrine/alpine-s6:3.13**: Alpine 3.13
- **nephatrine/alpine-s6:3.12**: Alpine 3.12
- **nephatrine/alpine-s6:3.11**: Alpine 3.11
- **nephatrine/alpine-s6:3.10**: Alpine 3.10

## Configuration Variables

You can set these parameters using the syntax ``-e "VARNAME=VALUE"`` on your
``docker run`` command. Some of these may only be used during initial
configuration and further changes may need to be made in the generated
configuration files.

- ``PUID``: Mount Owner UID (*1000*)
- ``PGID``: Mount Owner GID (*100*)
- ``TZ``: System Timezone (*America/New_York*)

## Persistent Mounts

You can provide a persistent mountpoint using the ``-v /host/path:/container/path``
syntax. These mountpoints are intended to house important configuration files,
logs, and application state (e.g. databases) so they are not lost on image
update.

- ``/mnt/config``: Persistent Data.

Do not share ``/mnt/config`` volumes between multiple containers as they may
interfere with the operation of one another.

You can perform some basic configuration of the container using the files and
directories listed below.

- ``/mnt/config/etc/crontabs/<user>``: User Crontabs. [*]
- ``/mnt/config/etc/logrotate.conf``: Logrotate Global Configuration.
- ``/mnt/config/etc/logrotate.d/``: Logrotate Additional Configuration.

**[*] Changes to some configuration files may require service restart to take
immediate effect.**
