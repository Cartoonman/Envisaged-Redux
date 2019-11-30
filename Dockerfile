# Envisaged Redux
# Copyright (c) 2019 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: MIT

FROM alpine:3.10 as gource-nightly-builder

RUN apk add --update --no-cache --virtual .build-deps alpine-sdk git sdl2-dev sdl2_image-dev pcre-dev freetype-dev glew-dev glm-dev boost-dev libpng-dev tinyxml-dev autoconf automake \
    && git clone https://github.com/acaudwell/Gource.git \
    && cd Gource \
    && ./autogen.sh \
    && ./configure \
    && make -j`nproc` \
    && make install \
    && cd / \
    && rm -rf Gource \
    && apk del .build-deps


FROM utensils/opengl:stable

COPY --from=gource-nightly-builder /usr/local/bin/gource /usr/local/bin/gource_nightly
COPY --from=gource-nightly-builder /usr/local/share/gource /usr/local/share/gource

RUN set -xe; \
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
        findutils \
        diffutils \ 
        curl \
        wget; \
    mkdir -p /visualization/html; \
    curl -L https://github.com/video-dev/hls.js/releases/download/v0.12.4/hls.light.min.js > /visualization/html/hls.light.min.js; \
    curl -L https://github.com/video-dev/hls.js/releases/download/v0.12.4/hls.light.min.js.map > /visualization/html/hls.light.min.js.map;


# Copy our assets
COPY html /visualization/html
COPY runtime /visualization/runtime
COPY LICENSE /visualization/LICENSE
COPY *.md /visualization/

WORKDIR /visualization


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
    org.label-schema.version="0.10.0"

# Set our default environment variables.
ENV H265_PRESET="medium" \
    H265_CRF="21" \
    VIDEO_RESOLUTION="1080p" \
    FPS="60" 

# Expose port 80 to serve mp4 video over HTTP
EXPOSE 80

SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["/visualization/runtime/entrypoint.sh"]
