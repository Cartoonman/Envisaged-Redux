#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. "$DIR/common.bash"

parse_args "$@"

if [ "${GIT_REPO_DIR}" = "" ]; then
    echo "No git repo directory specified, using Envisaged-Redux repo..."
    GIT_REPO_DIR=$DIR/../
fi

docker run --rm -i -t \
    -p 8080:80 \
    --name envisaged-redux \
    -v ${GIT_REPO_DIR}:/visualization/git_repo:ro \
    ${LOCAL_OUTPUT_URI} \
    ${CAPTION_URI} \
    ${AVATARS_URI} \
    ${LOGO_URI} \
    -e GOURCE_TITLE="Envisaged Redux" \
    -e GOURCE_CAMERA_MODE="overview" \
    -e GOURCE_SECONDS_PER_DAY=0.09 \
    -e GOURCE_AUTO_SKIP_SECONDS=1.0 \
    -e GOURCE_TIME_SCALE=1.0 \
    -e GOURCE_USER_SCALE=1.0 \
    -e GOURCE_MAX_USER_SPEED=500 \
    -e GOURCE_HIDE_ITEMS=mouse, \
    -e GOURCE_FILE_IDLE_TIME=0.0 \
    -e GOURCE_MAX_FILES=0 \
    -e GOURCE_MAX_FILE_LAG=3.0 \
    -e GOURCE_FILENAME_TIME=3.0 \
    -e GOURCE_FONT_SIZE= \
    -e GOURCE_FONT_COLOR= \
    -e GOURCE_BACKGROUND_COLOR= \
    -e GOURCE_DATE_FORMAT="%m/%d/%Y %H:%M:%S EST" \
    -e GOURCE_DIR_DEPTH=10 \
    -e GOURCE_BLOOM_MULTIPLIER=1.5 \
    -e GOURCE_BLOOM_INTENSITY=0.75 \
    -e GOURCE_PADDING=1.3 \
    -e GOURCE_HIGHLIGHT_ALL_USERS=1 \
    -e GOURCE_MULTI_SAMPLING=1 \
    -e GOURCE_SHOW_KEY=1 \
    -e ENABLE_LIVE_PREVIEW=1 \
    -e PREVIEW_SLOWDOWN_FACTOR=2 \
    ${ARGS} \
    cartoonman/envisaged-redux:latest