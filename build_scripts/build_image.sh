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
wget "https://github.com/twbs/bootstrap/releases/download/v4.0.0/bootstrap-4.0.0-dist.zip"
unzip bootstrap-4.0.0-dist.zip
rm bootstrap-4.0.0-dist.zip
wget "https://github.com/jquery/jquery/archive/3.3.1.zip"
unzip 3.3.1.zip
rm 3.3.1.zip
mv jquery-3.3.1/dist/* /visualization/html/js/
rm -rf 3.3.1