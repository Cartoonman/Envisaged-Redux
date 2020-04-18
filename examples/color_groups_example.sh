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
    GOURCE_TITLE                    "Color Groups Example" \
    GOURCE_CAMERA_MODE              "overview" \
    RUNTIME_TEMPLATE                "standard" \
    RENDER_VIDEO_RESOLUTION         "720p" \
    GOURCE_SECONDS_PER_DAY          "0.2" \
    GOURCE_AUTO_SKIP_SECONDS        "0.1" \
    GOURCE_FONT_SIZE                "42" \
    GOURCE_HIDE_ITEMS               "filenames" \
    GOURCE_DATE_FORMAT              "%m/%d/%Y" \
    GOURCE_PADDING                  "1.2" \
    GOURCE_HIGHLIGHT_USERS          "1" \
    GOURCE_MULTI_SAMPLING           "1" \
    RUNTIME_LIVE_PREVIEW            "1" \
    PREVIEW_SLOWDOWN_FACTOR         "2" \
    COLOR_GROUPS_SEED               "17285" \
    RUNTIME_COLOR_GROUPS            "1"

"${CUR_DIR_PATH}"/common/baseline.sh \
    "${env_vars[@]}" \
    --vcs-source-dir "${CUR_DIR_PATH}"/../ \
    "$@"

exit $?