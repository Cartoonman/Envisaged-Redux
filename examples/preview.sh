#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

declare -r CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. "${CUR_DIR_PATH}/common.bash"

parse_args "$@"


docker run --rm -i -t \
    -p 8080:80 \
    --name envisaged-redux \
    ${GIT_REPO_URI} \
    ${LOCAL_OUTPUT_URI} \
    ${CAPTION_URI} \
    ${AVATARS_URI} \
    ${LOGO_URI} \
    -e GOURCE_STOP_AT_TIME="5" \
    -e FPS="25" \
    -e VIDEO_RESOLUTION="480p" \
    -e GOURCE_TITLE="Fast Preview Example" \
    -e H265_PRESET="ultrafast" \
    -e H265_CRF="0" \
    -e GOURCE_DATE_FONT_SIZE="35" \
    -e GOURCE_TITLE_FONT_SIZE="25" \
    -e GOURCE_PADDING="1.5" \
    ${ARGS} \
    cartoonman/envisaged-redux:latest
