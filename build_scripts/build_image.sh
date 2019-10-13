#!/bin/sh

set -xe
apk --update add --no-cache --virtual .runtime-deps \
    bash \
    ffmpeg \
    git \
    gource \
    imagemagick \
    lighttpd \
    llvm7-libs \
    python \
    subversion \
    wget

cd /var/tmp
mkdir -p /visualization
cd /visualization
mkdir -p /visualization/video
mkdir -p /visualization/html
cd /visualization/html