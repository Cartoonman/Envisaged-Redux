#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH
source "${CUR_DIR_PATH}/common.bash"

parse_args "$@"

# Training Wheels. Remove or modify this section if using this script in your own setups.
if [[ "${vcs_source_uri}" == "" ]]; then
    echo "No git repo directory specified, using Envisaged-Redux repo..."
    vcs_source_uri=("--mount" "type=bind,src=${CUR_DIR_PATH}/../,dst=/visualization/resources/vcs_source,readonly")
    caption_uri=("--mount" "type=bind,src=${CUR_DIR_PATH}/data/quick_start_captions.txt,dst=/visualization/resources/captions.txt,readonly")
    avatars_uri=("--mount" "type=bind,src=${CUR_DIR_PATH}/data/quick_start_avatars,dst=/visualization/resources/avatars,readonly")
    logo_uri=("--mount" "type=bind,src=${CUR_DIR_PATH}/../docs/resources/envisaged_redux_logo.png,dst=/visualization/resources/logo.image,readonly")
fi

# Declare Environment Variables to configure Envisaged Redux
env_vars_declare \
    GOURCE_TITLE                    "Envisaged Redux" \
    GOURCE_CAMERA_MODE              "overview" \
    RENDER_VIDEO_RESOLUTION         "720p" \
    RUNTIME_TEMPLATE                "border" \
    GOURCE_CAPTION_SIZE             "32" \
    GOURCE_CAPTION_DURATION         "2.5" \
    GOURCE_SECONDS_PER_DAY          "0.09" \
    GOURCE_AUTO_SKIP_SECONDS        "0.5" \
    GOURCE_TIME_SCALE               "1.0" \
    GOURCE_USER_SCALE               "1.0" \
    GOURCE_MAX_USER_SPEED           "500" \
    GOURCE_FILE_IDLE_TIME           "0.0" \
    GOURCE_MAX_FILES                "0" \
    GOURCE_MAX_FILE_LAG             "5.0" \
    GOURCE_FILENAME_TIME            "5.0" \
    GOURCE_BORDER_TITLE_SIZE        "36" \
    GOURCE_BORDER_DATE_SIZE         "42" \
    GOURCE_BACKGROUND_COLOR         "000000" \
    GOURCE_DATE_FORMAT              "%m/%d/%Y %H:%M:%S" \
    GOURCE_BLOOM_MULTIPLIER         "1.5" \
    GOURCE_BLOOM_INTENSITY          "0.75" \
    GOURCE_PADDING                  "1.2" \
    GOURCE_HIGHLIGHT_ALL_USERS      "1" \
    GOURCE_MULTI_SAMPLING           "1" \
    RUNTIME_LIVE_PREVIEW            "1" \
    PREVIEW_SLOWDOWN_FACTOR         "2"

# Run Envisaged Redux
docker run --rm -it \
    -p 8080:80 \
    --name envisaged-redux \
    "${vcs_source_uri[@]}" \
    "${local_output_uri[@]}" \
    "${caption_uri[@]}" \
    "${avatars_uri[@]}" \
    "${logo_uri[@]}" \
    "${env_vars[@]}" \
    "${args[@]}" \
    cartoonman/envisaged-redux:latest
