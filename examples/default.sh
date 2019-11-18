#!/bin/bash

# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: MIT

DIR="${BASH_SRC%/*}"
if [[ ! -d  "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/common.bash"

parse_args $@

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