# Envisaged Redux
# Copyright (c) 2019 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: MIT

FROM alpine:3.10 

RUN set -xe; \
    apk --update add --no-cache --virtual .runtime-deps \
        bash \
        git \
        docker \
        imagemagick 


RUN git clone https://github.com/bats-core/bats-core.git \
&& cd bats-core \
&& ./install.sh /usr/local \
&& cd .. \
&& rm -r bats-core

SHELL ["/bin/bash", "-c"]
