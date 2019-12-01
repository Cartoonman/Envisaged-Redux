#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. "$DIR/common.bash"

parse_args "$@"

if [ "${GIT_REPO_DIR}" = "" ]; then
    echo "No git repo directory specified, using Envisaged-Redux repo..."
    GIT_REPO_DIR=$DIR/../
fi

docker run --rm -i -t \
    -p 8080:80 \
    --name envisaged-redux \
    -v ${GIT_REPO_DIR}:/visualization/git_repo:ro \
    ${LOCAL_OUTPUT_URI} \
    ${CAPTION_URI} \
    ${AVATARS_URI} \
    ${LOGO_URI} \
    ${ARGS} \
    cartoonman/envisaged-redux:latest