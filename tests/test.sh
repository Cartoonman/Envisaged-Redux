#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: MIT

# Entry Point into testing.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. ${DIR}/test_common.bash

IMAGE=$1

set -e

# Set up git test repo
GIT_PARENT_DIR="/workvol/git_sandbox"
mkdir -p ${GIT_PARENT_DIR}
echo "Initializing Git Test Sandbox..."
${DIR}/git_testbed.sh ${GIT_PARENT_DIR} > /dev/null 2>&1


# Unit tests
echo "Starting test"
bats ${DIR}/gource_arg_parse.bats




# Integration tests
mkdir /workvol/output
ls /
docker run --rm -d \
    --name ${IMAGE_NAME} \
    -v ev-test-volume:/workvol \
    ${IMAGE} \
    TEST



test=$(docker exec -t ${IMAGE_NAME} bash -c 'echo "hello there"' | tr -d '\r')
echo "$test"

docker exec \
-e RECURSE_SUBMODULES="1" 
-e FPS="60" \
-e ENABLE_LIVE_PREVIEW="1" \
-e PREVIEW_SLOWDOWN_FACTOR="2" \
-e VIDEO_RESOLUTION="720p" \
-e USE_GOURCE_NIGHTLY=1 \
-t ${IMAGE_NAME}

# Stop test container
docker stop ${IMAGE_NAME}

