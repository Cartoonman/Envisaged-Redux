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
    GOURCE_TITLE                    "Envisaged Redux" \
    GOURCE_CAMERA_MODE              "overview" \
    RUNTIME_TEMPLATE                "standard" \
    RENDER_VIDEO_RESOLUTION         "2160p" \
    GOURCE_SECONDS_PER_DAY          "0.2" \
    GOURCE_AUTO_SKIP_SECONDS        "0.1" \
    GOURCE_TIME_SCALE               "1.5" \
    GOURCE_USER_SCALE               "1.0" \
    GOURCE_FONT_SIZE                "96" \
    GOURCE_FONT_SCALE               "2.5" \
    GOURCE_HIDE_ITEMS               "filenames" \
    GOURCE_BACKGROUND_COLOR         "000000" \
    GOURCE_DATE_FORMAT              "%m/%d/%Y %H:%M:%S" \
    GOURCE_PADDING                  "1.5" \
    GOURCE_HIGHLIGHT_USERS          "1" \
    GOURCE_MULTI_SAMPLING           "1" \
    RUNTIME_LIVE_PREVIEW            "1" \
    PREVIEW_SLOWDOWN_FACTOR         "4"


"${CUR_DIR_PATH}"/common/baseline.sh \
    "${env_vars[@]}" \
    --vcs-source-dir "${CUR_DIR_PATH}"/../ \
    "$@"

exit $?