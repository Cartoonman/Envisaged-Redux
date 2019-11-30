# Envisaged Redux
# Copyright (c) 2019 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: MIT

FROM cartoonman/envisaged-redux

RUN apk add --update --no-cache --virtual .build-deps alpine-sdk autoconf texinfo ncurses-dev libxml2-dev \
&& wget http://ftp.gnu.org/gnu/wdiff/wdiff-1.2.2.tar.gz -O wdiff.tar.gz \
&& tar xf wdiff.tar.gz \
&& rm wdiff.tar.gz \
&& cd wdiff* \
&& ./configure --build=x86_64-linux-gnu --disable-silent-rules --disable-maintainer-mode --disable-dependency-tracking --with-default-pager=/usr/bin/pager LIBS=-lcurses \
&& make -j`nproc` && make install \
&& cd .. \
&& rm -r wdiff* \
&& apk del .build-deps

RUN git clone https://github.com/bats-core/bats-core.git \
&& cd bats-core \
&& ./install.sh /usr/local \
&& cd .. \
&& rm -r bats-core

COPY tests/ /visualization/tests/

ENTRYPOINT ["/visualization/tests/test.sh"]
