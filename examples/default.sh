#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH
source "${CUR_DIR_PATH}/common.bash"

parse_args "$@"

# Use env_vars_declare to customize the runtime behavior of Envisaged Redux.
# Example:
# env_vars_declare \
#     GOURCE_TITLE                    "My Software Project" \
#     GOURCE_CAMERA_MODE              "overview" \
#     RENDER_VIDEO_RESOLUTION         "1080p" \
#     RUNTIME_TEMPLATE                "standard"

docker run --rm -i -t \
    -p 8080:80 \
    --name envisaged-redux \
    "${vcs_source_uri[@]}" \
    "${custom_log_uri[@]}" \
    "${log_output_uri[@]}" \
    "${local_output_uri[@]}" \
    "${caption_uri[@]}" \
    "${avatars_uri[@]}" \
    "${logo_uri[@]}" \
    "${background_image_uri[@]}" \
    "${default_user_image_uri[@]}" \
    "${font_file_uri[@]}" \
    "${env_vars[@]}" \
    "${args[@]}" \
    cartoonman/envisaged-redux:latest
exit $?