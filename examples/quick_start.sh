#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

declare -r CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. "${CUR_DIR_PATH}/common.bash"

parse_args "$@"

# Training Wheels. Remove or modify this section if using this script in your own setups.
if [ "${GIT_REPO_URI}" = "" ]; then
    echo "No git repo directory specified, using Envisaged-Redux repo..."
    GIT_REPO_URI="--mount type=bind,src=${CUR_DIR_PATH}/../,dst=/visualization/git_repo,readonly"
    CAPTION_URI="--mount type=bind,src=${CUR_DIR_PATH}/data/quick_start_captions.txt,dst=/visualization/captions.txt,readonly"
fi

docker run --rm -it \
    -p 8080:80 \
    --name envisaged-redux \
    ${GIT_REPO_URI} \
    ${LOCAL_OUTPUT_URI} \
    ${CAPTION_URI} \
    ${AVATARS_URI} \
    ${LOGO_URI} \
    -e GOURCE_TITLE="Envisaged Redux" \
    -e GOURCE_CAMERA_MODE="overview" \
    -e VIDEO_RESOLUTION=720p \
    -e TEMPLATE="border" \
    -e GOURCE_CAPTION_SIZE=32 \
    -e GOURCE_CAPTION_DURATION=2.5 \
    -e GOURCE_SECONDS_PER_DAY=0.09 \
    -e GOURCE_AUTO_SKIP_SECONDS=0.5 \
    -e GOURCE_TIME_SCALE=1.0 \
    -e GOURCE_USER_SCALE=1.0 \
    -e GOURCE_MAX_USER_SPEED=500 \
    -e GOURCE_FILE_IDLE_TIME=0.0 \
    -e GOURCE_MAX_FILES=0 \
    -e GOURCE_MAX_FILE_LAG=5.0 \
    -e GOURCE_FILENAME_TIME=5.0 \
    -e GOURCE_BORDER_TITLE_FONT_SIZE=36 \
    -e GOURCE_BORDER_DATE_FONT_SIZE=42 \
    -e GOURCE_BACKGROUND_COLOR=000000 \
    -e GOURCE_DATE_FORMAT="%m/%d/%Y %H:%M:%S" \
    -e GOURCE_BLOOM_MULTIPLIER=1.5 \
    -e GOURCE_BLOOM_INTENSITY=0.75 \
    -e GOURCE_PADDING=1.2 \
    -e GOURCE_HIGHLIGHT_ALL_USERS=1 \
    -e GOURCE_MULTI_SAMPLING=1 \
    -e ENABLE_LIVE_PREVIEW=1 \
    -e PREVIEW_SLOWDOWN_FACTOR=2 \
    ${ARGS} \
    cartoonman/envisaged-redux:latest