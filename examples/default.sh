#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH
. "${CUR_DIR_PATH}/common.bash"

parse_args "$@"


docker run --rm -i -t \
    -p 8080:80 \
    --name envisaged-redux \
    ${GIT_REPO_URI} \
    ${LOCAL_OUTPUT_URI} \
    ${CAPTION_URI} \
    ${AVATARS_URI} \
    ${LOGO_URI} \
    ${ARGS} \
    cartoonman/envisaged-redux:latest