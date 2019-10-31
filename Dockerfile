# Envisaged - Dockerized Gource Visualizations

# Copyright (c) 2019 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: MIT

FROM utensils/opengl:stable

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
