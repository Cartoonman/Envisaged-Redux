# Envisaged Redux
# Copyright (c) 2019 Carl Colena
# Copyright (c) 2019 Utensils Union
# Copyright (c) 2018 James Brink
#
# SPDX-License-Identifier: Apache-2.0 AND MIT

FROM alpine:3.11 as alpine-base

ENV GOURCE_STABLE_VERSION="0.49" \
    MESA_VERSION="19.2.8" \
    LLVM_VERSION="llvm5" \
    FFMPEG_VERSION="4.2.2" \
    NASM_VERSION="2.14.02" \
    YASM_VERSION="1.3.0" \
    X264_VERSION="20191217-2245" \
    X265_VERSION="3.2.1"

FROM alpine-base as gource-builder

RUN apk add --update --no-cache --virtual .build-deps alpine-sdk git sdl2-dev sdl2_image-dev pcre-dev freetype-dev glew-dev glm-dev boost-dev libpng-dev tinyxml-dev autoconf automake \
    && mkdir -p /opt/gource_nightly /opt/gource_stable /sources \
    && git clone --branch master https://github.com/acaudwell/Gource.git \
    && cd Gource \
    && git archive -9 --format=tar.gz -o /sources/gource-nightly.tar.gz --prefix=gource-nightly/ master \
    && git archive -9 --format=tar.gz -o /sources/gource-"${GOURCE_STABLE_VERSION}".tar.gz --prefix=gource-"${GOURCE_STABLE_VERSION}"/ gource-"${GOURCE_STABLE_VERSION}" \
    && ./autogen.sh \
    && ./configure --prefix=/opt/gource_nightly \
    && make -j"$(nproc)" \
    && make install \
    && mv /opt/gource_nightly/bin/gource /opt/gource_nightly/bin/gource_nightly \
    && rm -rf * \
    && git checkout gource-"${GOURCE_STABLE_VERSION}" \
    && git checkout . \
    && ./autogen.sh \
    && ./configure -prefix=/opt/gource_stable \
    && make -j"$(nproc)" \
    && make install \
    && cd .. \
    && rm -rf Gource \
    && apk del .build-deps


FROM alpine-base as mesa-builder

RUN apk add --no-cache --virtual .mesa_build_deps  \
        cmake \
        meson \
        bison \
        build-base \
        expat-dev \
        flex \
        gettext \
        glproto \
        libtool \
        "${LLVM_VERSION}"-dev \
        py-mako \
        xorg-server-dev \
        python-dev \
        zlib-dev


RUN mkdir -p /var/tmp/build \
    && cd /var/tmp/build \
    && wget -q "https://mesa.freedesktop.org/archive/mesa-${MESA_VERSION}.tar.xz" \
    && tar xf mesa-"${MESA_VERSION}".tar.xz \
    && rm mesa-"${MESA_VERSION}".tar.xz \
    && cd mesa-"${MESA_VERSION}" \
    && printf "[binaries]\nllvm-config = '/usr/lib/${LLVM_VERSION}/bin/llvm-config'" \
		> "/var/tmp/build/llvm.ini" \
    && meson build/ \
        --native-file "/var/tmp/build/llvm.ini" \
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
        -D glx=gallium-xlib \
    && ninja -C build/ \
    && ninja -C build/ install \
    && rm -rf /var/tmp/build \
    && apk del .mesa_build_deps


FROM alpine-base as ffmpeg-builder

RUN apk add --update --no-cache \
        build-base \
        autoconf \
        automake \
        wget \
        tar \
        xz \
        bzip2 \
        gzip \
        bash \
        cmake \
        git \
        pkgconfig \
    && mkdir -p /opt/install /build_dir /sources/

WORKDIR /build_dir

# Build nasm from source
RUN mkdir -p nasm \
    && cd nasm \
    && wget -q https://www.nasm.us/pub/nasm/releasebuilds/"${NASM_VERSION}"/nasm-"${NASM_VERSION}".tar.xz \
    && tar --strip-components=1 -xf nasm-"${NASM_VERSION}".tar.xz \
    && rm nasm-"${NASM_VERSION}".tar.xz \
    && ./autogen.sh \
    && ./configure \
    && make -j"$(nproc)" \
    && make install

# Build yasm from source
RUN mkdir -p yasm \
    && cd yasm \
    && wget -q http://www.tortall.net/projects/yasm/releases/yasm-"${YASM_VERSION}".tar.gz \
    && tar --strip-components=1 -xf yasm-"${YASM_VERSION}".tar.gz \
    && rm yasm-"${YASM_VERSION}".tar.gz \
    && ./configure \
    && make -j"$(nproc)" \
    && make install


# Build libx264 from source
RUN mkdir -p x264 \
    && cd x264 \
    && wget -q http://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-"${X264_VERSION}"-stable.tar.bz2  \
    && tar --strip-components=1 -xf x264-snapshot-"${X264_VERSION}"-stable.tar.bz2 \
    && mv x264-snapshot-"${X264_VERSION}"-stable.tar.bz2 /sources/ \
    && ./configure \
        --disable-cli \
        --enable-shared \
        --enable-pic \
        --prefix=/opt/install \
        --bit-depth=all \
        --chroma-format=all \
    && make -j"$(nproc)" \
    && make install


# Build libx265 from source
RUN mkdir -p x265 \
    && cd x265 \
    && wget -q http://download.videolan.org/pub/videolan/x265/x265_"${X265_VERSION}".tar.gz  \
    && tar --strip-components=1 -xf x265_"${X265_VERSION}".tar.gz \
    && mv x265_"${X265_VERSION}".tar.gz /sources/ \
    && cd build \
    && cmake ../source \
        -DENABLE_CLI:bool=OFF \
        -DHIGH_BIT_DEPTH:bool=ON \
        -DCMAKE_INSTALL_PREFIX=/opt/install \
        -DCMAKE_BUILD_TYPE="Release" \
        -DMAIN12:bool=ON \
        -DENABLE_ASSEMBLY:bool=ON \
        -DENABLE_PIC:bool=ON \
        -DENABLE_SVT_HEVC:bool=ON \
        -DENABLE_LIBNUMA:bool=OFF \
    && make -j"$(nproc)" \
    && make install

# Build ffmpeg from source.
RUN mkdir -p ffmpeg \
    && cd ffmpeg \
    && cp -r /opt/install/* /usr/local/ \
    && wget -q https://www.ffmpeg.org/releases/ffmpeg-"${FFMPEG_VERSION}".tar.xz \
    && tar --strip-components=1 -xf ffmpeg-"${FFMPEG_VERSION}".tar.xz \
    && mv ffmpeg-"${FFMPEG_VERSION}".tar.xz /sources/ \
    && ./configure \
        --prefix=/opt/install \
        --enable-gpl \
        --disable-static --enable-shared \
        --disable-ffplay \
        --disable-ffprobe \
        --disable-devices \
        --disable-doc \
        --disable-network \
        --disable-debug \
        --enable-libx265 \
        --enable-libx264 \
        --enable-demuxer=image2pipe \
    && make -j"$(nproc)" \
    && make install


FROM alpine-base

COPY --from=mesa-builder /usr/local /usr/local
COPY --from=gource-builder /opt/gource_nightly /opt/gource_nightly
COPY --from=gource-builder /opt/gource_stable /opt/gource_stable
COPY --from=gource-builder /sources /gpl_sources
COPY --from=ffmpeg-builder /opt/install /usr/local
COPY --from=ffmpeg-builder /sources /gpl_sources

ENV PATH="/opt/gource_stable/bin:/opt/gource_nightly/bin:${PATH}"

RUN apk --update add --no-cache --virtual .runtime-deps \
        boost-filesystem freetype glew glu libgcc libpng libstdc++ mesa-gl musl pcre sdl2 sdl2_image \
        bash \
        expat \
        ${LLVM_VERSION}-libs \
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
        wget \
    && mkdir -p /visualization/html \
    && curl -L -s https://github.com/video-dev/hls.js/releases/download/v0.13.1/hls.light.min.js > /visualization/html/hls.light.min.js \
    && curl -L -s https://github.com/video-dev/hls.js/releases/download/v0.13.1/hls.light.min.js.map > /visualization/html/hls.light.min.js.map;


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
    org.label-schema.version="0.12.0"

# Expose port 80 to serve mp4 video over HTTP
EXPOSE 80

SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["/visualization/runtime/entrypoint.sh"]
