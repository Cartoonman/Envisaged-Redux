#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH
source "${CUR_DIR_PATH}/common.bash"

parse_args "$@"


# Declare Environment Variables to configure Envisaged Redux
env_vars_declare \
    GOURCE_STOP_AT_TIME         "5" \
    RENDER_FPS                  "25" \
    RUNTIME_TEMPLATE            "standard" \
    RENDER_VIDEO_RESOLUTION     "480p" \
    GOURCE_TITLE                "Fast Preview Example" \
    RENDER_H265_PRESET          "ultrafast" \
    RENDER_H265_CRF             "0" \
    GOURCE_FONT_SIZE            "35" \
    GOURCE_PADDING              "1.5"


docker run --rm -i -t \
    -p 8080:80 \
    --name envisaged-redux \
    "${vcs_source_uri[@]}" \
    "${local_output_uri[@]}" \
    "${caption_uri[@]}" \
    "${avatars_uri[@]}" \
    "${logo_uri[@]}" \
    "${background_image_uri[@]}" \
    "${default_user_image_uri[@]}" \
    "${env_vars[@]}" \
    "${args[@]}" \
    cartoonman/envisaged-redux:latest
