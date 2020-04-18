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
    RUNTIME_TEMPLATE            "standard" \
    RENDER_VIDEO_RESOLUTION     "480p" \
    GOURCE_TITLE                "Fast Alt Preview Example" \
    RENDER_CODEC                "h264" \
    GOURCE_SECONDS_PER_DAY      "0.2" \
    GOURCE_TIME_SCALE           "2" \
    GOURCE_AUTO_SKIP_SECONDS    "0.1" \
    GOURCE_DATE_FORMAT          "%m/%d/%Y" \
    GOURCE_HIDE_ITEMS           "filenames" \
    RENDER_H264_PRESET          "ultrafast" \
    RENDER_H264_CRF             "0" \
    GOURCE_FONT_SIZE            "35" \
    GOURCE_PADDING              "1.5"

"${CUR_DIR_PATH}"/common/baseline.sh \
    "${env_vars[@]}" \
    --vcs-source-dir "${CUR_DIR_PATH}"/../ \
    "$@"
    
exit $?