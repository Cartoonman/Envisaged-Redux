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
    GOURCE_TITLE                    "Headless Example" \
    GOURCE_CAMERA_MODE              "overview" \
    RENDER_VIDEO_RESOLUTION         "1080p" \
    RUNTIME_PRINT_VARS              "1" \
    RUNTIME_TEMPLATE                "standard" \
    RENDER_CODEC                    "h264" \
    RENDER_FPS                      "60" \
    RENDER_PROFILE                  "baseline" \
    RENDER_LEVEL                    "3.0" \
    RENDER_VERBOSE                  "1" \
    RENDER_NO_PROGRESS              "1" \
    RENDER_H264_PRESET              "medium" \
    RENDER_H264_CRF                 "18" \
    GOURCE_SECONDS_PER_DAY          "0.1" \
    GOURCE_AUTO_SKIP_SECONDS        "0.1" \
    GOURCE_MAX_FILE_LAG             "5.0" \
    GOURCE_FONT_SIZE                "60" \
    GOURCE_SHOW_KEY                 "1" \
    GOURCE_HIDE_ITEMS               "filenames" \
    GOURCE_DATE_FORMAT              "%m/%d/%Y" \
    GOURCE_HIGHLIGHT_USERS          "1" \
    GOURCE_MULTI_SAMPLING           "1" \

"${CUR_DIR_PATH}"/common/baseline.sh \
    "${env_vars[@]}" \
    --vcs-source-dir "${CUR_DIR_PATH}"/../ \
    --video-output-dir "${CUR_DIR_PATH}" \
    "$@"
    
exit $?