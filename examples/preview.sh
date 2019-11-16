#!/bin/bash

# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: MIT

DIR="${BASH_SRC%/*}"
if [[ ! -d  "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/common.bash"

parse_args $@

if [ "${GIT_REPO_DIR}" = "" ]; then
    echo "No git repo directory specified, using Envisaged-Redux repo..."
    GIT_REPO_DIR=$DIR/../
fi

docker run --rm -i -t \
    -p 8080:80 \
    --name envisaged-redux \
    -v ${GIT_REPO_DIR}:/visualization/git_repo:ro \
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
    $ARGS \
    envisaged-redux:latest
