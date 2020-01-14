# Envisaged Redux
# Copyright (c) 2019 Carl Colena
# Copyright (c) 2019 Utensils Union
# Copyright (c) 2018 James Brink
#
# SPDX-License-Identifier: Apache-2.0 AND MIT

FROM alpine:3.11 as gource-nightly-builder

RUN apk add --update --no-cache --virtual .build-deps alpine-sdk git sdl2-dev sdl2_image-dev pcre-dev freetype-dev glew-dev glm-dev boost-dev libpng-dev tinyxml-dev autoconf automake \
    && git clone --branch master --depth 1 https://github.com/acaudwell/Gource.git \
    && cd Gource \
    && ./autogen.sh \
    && ./configure \
    && make -j"$(nproc)" \
    && make install \
    && cd .. \
    && rm -rf Gource \
    && apk del .build-deps


# Note the below section is based on:
# https://github.com/utensils/docker-opengl/

FROM alpine:3.11 as mesa_builder
ENV MESA_VERSION 19.2.8

# Install all needed build deps for Mesa
RUN set -xe; \
    apk add --no-cache --virtual .mesa_build_deps  \
        cmake \
        meson \
        bison \
        build-base \
        expat-dev \
        flex \
        gettext \
        glproto \
        libtool \
        llvm9 \
        llvm9-dev \
        py-mako \
        xorg-server-dev python-dev \
        zlib-dev;


RUN set -xe; \
    mkdir -p /var/tmp/build; \
    cd /var/tmp/build; \
    wget -q "https://mesa.freedesktop.org/archive/mesa-${MESA_VERSION}.tar.xz"; \
    tar xf mesa-"${MESA_VERSION}".tar.xz; \
    rm mesa-"${MESA_VERSION}".tar.xz; \
    cd mesa-"${MESA_VERSION}"; \
    meson build/ \
        -D prefix=/usr/local \
        -D osmesa=gallium \
        -D dri-drivers=[] \
        -D vulkan-drivers=[] \
        -D platforms=x11 \
        -D gallium-drivers=swrast \
        -D dri3=false \
        -D gbm=false \
        -D egl=false \
        -D llvm=true \
        -D glx=gallium-xlib; \
    ninja -C build/; \
    ninja -C build/ install; \
    rm -rf /var/tmp/build; \
    apk del .mesa_build_deps


FROM alpine:3.11

COPY --from=mesa_builder /usr/local /usr/local
COPY --from=gource-nightly-builder /usr/local/bin/gource /usr/local/bin/gource_nightly
COPY --from=gource-nightly-builder /usr/local/share/gource /usr/local/share/gource

RUN set -xe; \
    apk --update add --no-cache --virtual .runtime-deps \
        bash \
        expat \
        llvm9-libs \
        xdpyinfo \
        xvfb \
        git \
        gource \
        imagemagick \
        lighttpd \
        python \
        subversion \
        findutils \
        curl \
        wget; \
    mkdir -p /visualization/html; \
    curl -L https://github.com/video-dev/hls.js/releases/download/v0.13.1/hls.light.min.js > /visualization/html/hls.light.min.js; \
    curl -L https://github.com/video-dev/hls.js/releases/download/v0.13.1/hls.light.min.js.map > /visualization/html/hls.light.min.js.map; \
    wget https://www.johnvansickle.com/ffmpeg/old-releases/ffmpeg-4.1.4-amd64-static.tar.xz -q -O ffmpeg.tar.xz; \
    tar xf ffmpeg.tar.xz; \
    rm ffmpeg.tar.xz; \
    mv ffmpeg*/ffmpeg /usr/local/bin/ffmpeg; \
    rm -r ffmpeg*;


# Copy our assets
COPY html /visualization/html
COPY runtime /visualization/runtime
COPY LICENSE /visualization/LICENSE
COPY VERSION /visualization/VERSION
COPY *.md /visualization/

WORKDIR /visualization

ENV GALLIUM_DRIVER="llvmpipe" \
    LIBGL_ALWAYS_SOFTWARE="1" \
    LP_NO_RAST="false" \
    XVFB_WHD="3840x2160x24" \
    DISPLAY=":99" 

# Labels and metadata.
ARG VCS_REF
ARG BUILD_DATE
LABEL maintainer="Carl Colena, carl.colena@gmail.com" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.decription="Envisaged Redux - Dockerized Gource Visualizations, Reborn" \
    org.label-schema.name="Envisaged Redux" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.vcs-ref="${VCS_REF}" \
    org.label-schema.vcs-url="https://gitlab.com/Cartoonman/Envisaged-Redux" \
    org.label-schema.vendor="Carl Colena" \
    org.label-schema.version="0.11.0"

# Expose port 80 to serve mp4 video over HTTP
EXPOSE 80

SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["/visualization/runtime/entrypoint.sh"]
