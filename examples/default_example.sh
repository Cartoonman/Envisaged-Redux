#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH
source "${CUR_DIR_PATH}/common/common.bash"

# Declare Environment Variables to configure Envisaged Redux
# Use env_vars_declare to customize the runtime behavior of Envisaged Redux.
# Example:
# env_vars_declare \
#     GOURCE_TITLE                    "My Software Project" \
#     GOURCE_CAMERA_MODE              "overview" \
#     RENDER_VIDEO_RESOLUTION         "1080p" \
#     RUNTIME_TEMPLATE                "standard"

"${CUR_DIR_PATH}"/common/baseline.sh \
    "${env_vars[@]}" \
    --vcs-source-dir "${CUR_DIR_PATH}"/../ \
    "$@"
    
exit $?