# Envisaged - Dockerized Gource Visualizations
#
# VERSION 0.1.4

# Mesa3D Software Drivers

FROM alpine:3.10 as builder

ENV MESA_VERSION 19.0.8

# Install all needed build deps for Mesa
RUN set -xe; \
    apk add --no-cache \
        autoconf \
        automake \
        bison \
        build-base \
        expat-dev \
        flex \
        gettext \
        git \
        glproto \
        libtool \
        llvm7 \
        llvm7-dev \
        py-mako \
        xorg-server-dev python-dev \
        zlib-dev;

# Clone Mesa source repo. (this step caches)
# Due to ongoing packaging issues we build from git vs tar packages
# Refer to https://bugs.freedesktop.org/show_bug.cgi?id=107865 

ARG MESA_VERSION
RUN set -xe; \
    mkdir -p /var/tmp/build; \
    cd /var/tmp/build; \
    git clone https://gitlab.freedesktop.org/mesa/mesa.git; \
    cd /var/tmp/build/mesa; \
    git checkout mesa-${MESA_VERSION}; \
    libtoolize; \
    autoreconf --install; \
    ./configure \
        --enable-glx=gallium-xlib \
        --with-gallium-drivers=swrast,swr \
        --disable-dri \
        --disable-gbm \
        --disable-egl \
        --enable-gallium-osmesa \
        --enable-autotools \
        --enable-llvm \
        --with-llvm-prefix=/usr/lib/llvm7/ \
        --prefix=/usr/local; \
    make -j$(getconf _NPROCESSORS_ONLN); \
    make install; \
    rm -rf /var/tmp/build

# Create fresh image from alpine
FROM alpine:3.10

# Install runtime dependencies for Mesa
RUN set -xe; \
    apk --update add --no-cache \
        expat \
        llvm7-libs \
        xdpyinfo \
        xvfb;

# Copy the Mesa build & entrypoint script from previous stage
COPY --from=builder /usr/local /usr/local

# Setup our environment variables.
ENV GALLIUM_DRIVER="llvmpipe" \
    LIBGL_ALWAYS_SOFTWARE="1" \
    LP_NO_RAST="false" \
    MESA_VERSION="${MESA_VERSION}" \
    XVFB_WHD="3840x2160x24" \
    DISPLAY=":99" 

# **************************************************************

# Install all needed runtime dependencies.
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
        wget; \
    mkdir -p /visualization/video; \
    mkdir -p /visualization/html; 


# Copy our assets
COPY ./docker-entrypoint.sh /usr/local/bin/entrypoint.sh
COPY . /visualization/

WORKDIR /visualization

# Set our default environment variables.

ENV LOGO_URL="" \ 
    H265_PRESET="medium" \
    H265_CRF="21" \
    VIDEO_RESOLUTION="1080p" \
    FPS="60" \
    TEMPLATE="border" \
    RECURSE_SUBMODULES="0" \
    GOURCE_TITLE="Software Development" \
    GOURCE_USER_IMAGE_DIR="/visualization/avatars" \
    GOURCE_DATE_FONT_COLOR="FFFFFF" \
    GOURCE_TITLE_TEXT_COLOR="FFFFFF" \
    GOURCE_CAMERA_MODE="overview" \
    GOURCE_SECONDS_PER_DAY="0.1" \
    GOURCE_TIME_SCALE="1.0" \
    GOURCE_USER_SCALE="1.0" \
    GOURCE_AUTO_SKIP_SECONDS="3.0" \
    GOURCE_BACKGROUND_COLOR="000000" \
    GOURCE_HIDE_ITEMS="mouse,date,filenames" \
    GOURCE_FILE_IDLE_TIME="0" \
    GOURCE_MAX_FILES="0" \
    GOURCE_MAX_FILE_LAG="5.0" \
    GOURCE_TITLE_FONT_SIZE="48" \
    GOURCE_DATE_FONT_SIZE="60" \
    GOURCE_DIR_DEPTH="3" \
    GOURCE_FILENAME_TIME="2" \
    GOURCE_MAX_USER_SPEED="500" \
    INVERT_COLORS="false" \
    GLOBAL_FILTERS="" \
    GOURCE_FILTERS="" \
    GOURCE_DATE_FORMAT="%m/%d/%Y %H:%M:%S" \
    GOURCE_START_DATE="" \
    GOURCE_STOP_DATE="" \
    GOURCE_START_POSITION="" \
    GOURCE_STOP_POSITION="" \
    GOURCE_STOP_AT_TIME="" \
    GOURCE_PADDING="1.1" \
    GOURCE_CAPTION_SIZE="48" \
    GOURCE_CAPTION_COLOR="FFFFFF" \
    GOURCE_CAPTION_DURATION="5.0"



# Expose port 80 to serve mp4 video over HTTP
EXPOSE 80

CMD ["/usr/local/bin/entrypoint.sh"]
