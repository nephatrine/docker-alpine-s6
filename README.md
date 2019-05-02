[Gitea](https://code.nephatrine.net/nephatrine/docker-alpine-s6) |
[DockerHub](https://hub.docker.com/r/nephatrine/alpine-s6/) |
[unRAID](https://code.nephatrine.net/nephatrine/unraid-containers)

# Alpine, S6, & S6-Overlay (Base)

This docker image is Alpine Linux with the Skarnet S6 supervisor and overlay
installed. It has no function on its own and is intended to be used as a base
for other docker images.

- [Alpine Linux](https://alpinelinux.org/)
- [Skarnet Software](https://skarnet.org/software/)
- [S6 Overlay](https://github.com/just-containers/s6-overlay)

You can spin up a quick temporary test container like this:

~~~
docker run -rm -ti nephatrine/alpine-s6:latest /bin/bash
~~~

## Docker Tags

- **nephatrine/alpine-s6:latest**: Alpine Current Release (*alpine:latest*)
- **nephatrine/alpine-s6:testing**: Alpine Testing Release (*alpine:edge*)

## Configuration Variables

You can set these parameters using the syntax ``-e "VARNAME=VALUE"`` on your
``docker run`` command. These are typically used during the container
initialization scripts to perform initial setup.

- ``PUID``: Mount Owner UID (*1000*)
- ``PGID``: Mount Owner GID (*100*)
- ``TZ``: System Timezone (*America/New_York*)

## Persistent Mounts

You can provide a persistent mountpoint using the ``-v /host/path:/container/path``
syntax. These mountpoints are intended important configuration files, logs,
and application state (e.g. databases) can be retained outside the container
image and are not lost on image updates.

- ``/mnt/config``: Configuration & Logs. Do not share with multiple containers.

You can perform some basic configuration and troubleshooting of the container
using the files and directories listed below.

- ``/mnt/config/bin/``: User Scripts.
- ``/mnt/config/etc/crontabs/<user>``: User Crontabs. [*]
- ``/mnt/config/etc/logrotate.conf``: Logrotate Global Configuration.
- ``/mnt/config/etc/logrotate.d/``: Logrotate Additional Configuration.
- ``/mnt/config/log/``: Application Logs.

**[*] Changes to some configuration files may require service restart to take
immediate effect.**

Some configuration files are required for system operation and will be
recreated with their default settings if deleted.

## Network Services

No ports or services exposed.
