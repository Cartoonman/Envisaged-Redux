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
    RENDER_VIDEO_RESOLUTION         "720p" \
    GOURCE_CAPTION_SIZE             "32" \
    GOURCE_CAPTION_DURATION         "5.0" \
    GOURCE_SECONDS_PER_DAY          "0.2" \
    GOURCE_AUTO_SKIP_SECONDS        "0.1" \
    GOURCE_TIME_SCALE               "1.5" \
    GOURCE_USER_SCALE               "1.0" \
    GOURCE_MAX_USER_SPEED           "500" \
    GOURCE_FILE_IDLE_TIME           "0.0" \
    GOURCE_MAX_FILES                "0" \
    GOURCE_MAX_FILE_LAG             "5.0" \
    GOURCE_FILENAME_TIME            "5.0" \
    GOURCE_FONT_SIZE                "42" \
    GOURCE_HIDE_ITEMS               "filenames" \
    GOURCE_BACKGROUND_COLOR         "000000" \
    GOURCE_DATE_FORMAT              "%m/%d/%Y %H:%M:%S" \
    GOURCE_BLOOM_MULTIPLIER         "1.5" \
    GOURCE_BLOOM_INTENSITY          "0.75" \
    GOURCE_PADDING                  "1.2" \
    GOURCE_HIGHLIGHT_USERS          "1" \
    GOURCE_MULTI_SAMPLING           "1" \
    RUNTIME_LIVE_PREVIEW            "1" \
    PREVIEW_SLOWDOWN_FACTOR         "2" \
    GOURCE_SHOW_KEY                 "1"


"${CUR_DIR_PATH}"/common/baseline.sh \
    "${env_vars[@]}" \
    --vcs-source-dir "${CUR_DIR_PATH}"/../ \
    --caption-file "${CUR_DIR_PATH}"/data/quick_start_captions.txt \
    --avatars-dir "${CUR_DIR_PATH}"/data/quick_start_avatars \
    --logo-file "${CUR_DIR_PATH}"/../docs/resources/envisaged_redux_logo.png \
    "$@"

exit $?