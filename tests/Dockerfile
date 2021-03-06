# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

FROM alpine:3.11 as wdiff-build

RUN apk add --update --no-cache --virtual .build-deps wget alpine-sdk autoconf texinfo ncurses-dev libxml2-dev diffutils bash \
    && wget http://ftp.gnu.org/gnu/wdiff/wdiff-1.2.2.tar.gz -q -O wdiff.tar.gz \
    && tar xf wdiff.tar.gz \
    && rm wdiff.tar.gz \
    && cd wdiff* \
    && ./configure --build=x86_64-linux-gnu --disable-silent-rules --with-default-pager=/usr/bin/pager LIBS=-lcurses \
    && make -j"$(nproc)" && make install \
    && cd .. \
    && rm -r wdiff* \
    && apk del .build-deps

FROM alpine:3.11 as bats-core-build

RUN apk add --update --no-cache --virtual .build-deps git bash \
    && git clone https://github.com/bats-core/bats-core.git \
    && cd bats-core \
    && git checkout 87b16eb8ec381beca7f05d028e4ad7cf3f647a0f \
    && ./install.sh /usr/local \
    && cd .. \
    && rm -r bats-core \
    && apk del .build-deps


FROM cartoonman/envisaged-redux:latest

RUN apk add --update --no-cache diffutils 
COPY --from=wdiff-build /usr/local /usr/local
COPY --from=bats-core-build /usr/local /usr/local
COPY tests/ /visualization/tests/

ENTRYPOINT ["/visualization/tests/test.sh"]
