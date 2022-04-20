FROM alpine:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"
RUN apk add --no-cache autoconf bison build-base clang git go linux-headers npm re2c
RUN mkdir /usr/src
