#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH
source "${CUR_DIR_PATH}/common/common.bash"

# Declare Environment Variables to configure Envisaged Redux
env_vars_declare \
    RENDER_FPS                  "25" \
    RENDER_VIDEO_RESOLUTION     "720p" \
    RUNTIME_TEMPLATE            "standard" \
    RENDER_CODEC                "h264" \
    GOURCE_TITLE                "Alternate Default Image Example" \
    GOURCE_COLOR_IMAGES         "1" \
    GOURCE_SECONDS_PER_DAY      "0.2" \
    GOURCE_AUTO_SKIP_SECONDS    "0.1" \
    GOURCE_HIDE_ITEMS           "filenames" \
    GOURCE_FONT_SIZE            "45" \
    RUNTIME_LIVE_PREVIEW        "1" \
    PREVIEW_SLOWDOWN_FACTOR     "2"

"${CUR_DIR_PATH}"/common/baseline.sh \
    "${env_vars[@]}" \
    --vcs-source-dir "${CUR_DIR_PATH}"/../ \
    --default-user-image-file "${CUR_DIR_PATH}"/data/cube.png \
    "$@"
    
exit $?