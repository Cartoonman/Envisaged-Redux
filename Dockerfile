# Envisaged Redux
# Copyright (c) 2020 Carl Colena
# Copyright (c) 2019 Utensils Union
# Copyright (c) 2018 James Brink
#
# SPDX-License-Identifier: Apache-2.0 AND MIT

FROM alpine:3.11 as alpine-base
# tag::dep_versions[]
ENV VERSION_STABLE_GOURCE="0.51" \
    VERSION_MESA="19.3.5" \
    VERSION_LLVM="llvm9" \
    VERSION_FFMPEG="4.2.2" \
    VERSION_NASM="2.14.02" \
    VERSION_YASM="1.3.0" \
    VERSION_X264="20191217-2245" \
    VERSION_X265="3.2.1" \
    VERSION_HLS_JS="0.13.2"
# end::dep_versions[]

FROM alpine-base as gource-builder

RUN apk add --update --no-cache --virtual .build-deps alpine-sdk git sdl2-dev sdl2_image-dev pcre-dev freetype-dev glew-dev glm-dev boost-dev libpng-dev tinyxml-dev autoconf automake pcre2-dev \
    && mkdir -p /opt/gource_nightly /opt/gource_stable /sources \
    && git clone --branch master https://github.com/acaudwell/Gource.git \
    && cd Gource \
    && git archive -9 --format=tar.gz -o /sources/gource-nightly.tar.gz --prefix=gource-nightly/ master \
    && git archive -9 --format=tar.gz -o /sources/gource-"${VERSION_STABLE_GOURCE}".tar.gz --prefix=gource-"${VERSION_STABLE_GOURCE}"/ gource-"${VERSION_STABLE_GOURCE}" \
    && ./autogen.sh \
    && ./configure --prefix=/opt/gource_nightly \
    && make -j"$(nproc)" \
    && make install \
    && mv /opt/gource_nightly/bin/gource /opt/gource_nightly/bin/gource_nightly \
    && rm -rf * \
    && git checkout gource-"${VERSION_STABLE_GOURCE}" \
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
        "${VERSION_LLVM}"-dev \
        py-mako \
        xorg-server-dev \
        python-dev \
        wget \
        zlib-dev


RUN mkdir -p /var/tmp/build \
    && cd /var/tmp/build \
    && wget -q "https://mesa.freedesktop.org/archive/mesa-${VERSION_MESA}.tar.xz" \
    && tar xf mesa-"${VERSION_MESA}".tar.xz \
    && rm mesa-"${VERSION_MESA}".tar.xz \
    && cd mesa-"${VERSION_MESA}" \
    && printf "[binaries]\nllvm-config = '/usr/lib/${VERSION_LLVM}/bin/llvm-config'" \
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
        zlib-dev \
        pkgconfig \
    && mkdir -p /opt/install /build_dir /sources/

WORKDIR /build_dir

# Build nasm from source
RUN mkdir -p nasm \
    && cd nasm \
    && wget -q https://www.nasm.us/pub/nasm/releasebuilds/"${VERSION_NASM}"/nasm-"${VERSION_NASM}".tar.xz \
    && tar --strip-components=1 -xf nasm-"${VERSION_NASM}".tar.xz \
    && rm nasm-"${VERSION_NASM}".tar.xz \
    && ./autogen.sh \
    && ./configure \
    && make -j"$(nproc)" \
    && make install

# Build yasm from source
RUN mkdir -p yasm \
    && cd yasm \
    && wget -q http://www.tortall.net/projects/yasm/releases/yasm-"${VERSION_YASM}".tar.gz \
    && tar --strip-components=1 -xf yasm-"${VERSION_YASM}".tar.gz \
    && rm yasm-"${VERSION_YASM}".tar.gz \
    && ./configure \
    && make -j"$(nproc)" \
    && make install


# Build libx264 from source
RUN mkdir -p x264 \
    && cd x264 \
    && wget -q http://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-"${VERSION_X264}"-stable.tar.bz2  \
    && tar --strip-components=1 -xf x264-snapshot-"${VERSION_X264}"-stable.tar.bz2 \
    && mv x264-snapshot-"${VERSION_X264}"-stable.tar.bz2 /sources/ \
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
    && wget -q http://download.videolan.org/pub/videolan/x265/x265_"${VERSION_X265}".tar.gz  \
    && tar --strip-components=1 -xf x265_"${VERSION_X265}".tar.gz \
    && mv x265_"${VERSION_X265}".tar.gz /sources/ \
    && mkdir -p build_8 build_10 build_12 \
    && cd build_12 \
    && cmake ../source \
        -DENABLE_CLI:bool=OFF \
        -DCMAKE_BUILD_TYPE="Release" \
        -DENABLE_ASSEMBLY:bool=ON \
        -DENABLE_LIBNUMA:bool=OFF \
        -DENABLE_SHARED:bool=OFF \
        -DEXPORT_C_API:bool=OFF \
        -DHIGH_BIT_DEPTH:bool=ON \
        -DMAIN12:bool=ON; \
    make -j"$(nproc)" & \
    p12_build=$!; \
    cd ../build_10 \
    && cmake ../source \
        -DENABLE_CLI:bool=OFF \
        -DCMAKE_BUILD_TYPE="Release" \
        -DENABLE_ASSEMBLY:bool=ON \
        -DENABLE_LIBNUMA:bool=OFF \
        -DENABLE_SHARED:bool=OFF \
        -DEXPORT_C_API:bool=OFF \
        -DHIGH_BIT_DEPTH:bool=ON; \
    make -j"$(nproc)" & \
    p10_build=$!; \
    wait "${p12_build}" "${p10_build}" \
    && cd ../build_8 \
    && mv ../build_12/libx265.a libx265_main12.a \
    && mv ../build_10/libx265.a libx265_main10.a \
    && cmake ../source \
        -DENABLE_CLI:bool=OFF \
        -DCMAKE_INSTALL_PREFIX=/opt/install \
        -DCMAKE_BUILD_TYPE="Release" \
        -DENABLE_ASSEMBLY:bool=ON \
        -DENABLE_PIC:bool=ON \
        -DENABLE_SVT_HEVC:bool=ON \
        -DENABLE_LIBNUMA:bool=OFF \
        -DEXTRA_LIB="libx265_main12.a;libx265_main10.a" \
        -DEXTRA_LINK_FLAGS=-L. \
        -DLINKED_10BIT:bool=ON \
        -DLINKED_12BIT:bool=ON \
        -DENABLE_SHARED:bool=OFF \
    && make -j"$(nproc)" \
    && mv libx265.a libx265_main.a \
    && printf "%s\n" \
        "CREATE libx265.a" \
        "ADDLIB libx265_main.a" \
        "ADDLIB libx265_main10.a" \
        "ADDLIB libx265_main12.a" \
        "SAVE" \
        "END" > ar_cmd.mri \
    && ar -M <ar_cmd.mri \
    && make install

# Build ffmpeg from source.
RUN mkdir -p ffmpeg \
    && cd ffmpeg \
    && cp -r /opt/install/* /usr/local/ \
    && wget -q https://www.ffmpeg.org/releases/ffmpeg-"${VERSION_FFMPEG}".tar.xz \
    && tar --strip-components=1 -xf ffmpeg-"${VERSION_FFMPEG}".tar.xz \
    && mv ffmpeg-"${VERSION_FFMPEG}".tar.xz /sources/ \
    && ./configure \
        --prefix=/opt/install \
        --pkg-config-flags="--static" \
        --extra-libs="-lpthread -lm" \
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
        --enable-decoder=png \
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
        "${VERSION_LLVM}"-libs \
        xdpyinfo \
        xvfb \
        git \
        pcre-tools \
        coreutils \
        imagemagick \
        lighttpd \
        findutils \
        curl \
        wget \
    && mkdir -p /visualization/html \
    && cd /visualization/html \
    && wget -q https://github.com/video-dev/hls.js/releases/download/v"${VERSION_HLS_JS}"/hls.light.min.js \
    && wget -q https://github.com/video-dev/hls.js/releases/download/v"${VERSION_HLS_JS}"/hls.light.min.js.map \
    && mkdir -p /visualization/resources


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
ARG BUILD_VERSION
LABEL maintainer="Carl Colena, carl.colena@gmail.com" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.decription="Containerized Gource + FFmpeg Visualizations" \
    org.label-schema.name="Envisaged Redux" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.vcs-ref="${VCS_REF}" \
    org.label-schema.vcs-url="https://gitlab.com/Cartoonman/Envisaged-Redux" \
    org.label-schema.vendor="Carl Colena" \
    org.label-schema.version="${BUILD_VERSION}"

# Expose port 80 to serve mp4 video over HTTP
EXPOSE 80

SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["/visualization/runtime/entrypoint.sh"]
