#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: MIT

# Entry Point into testing.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. ${DIR}/test_common.bash

SAVE=0
COUNT=1
while [[ $# -gt 0 ]]; do
    k="$1"
    case $k in
        -s)
            SAVE=1
            ;;
    esac
    shift
done

integration_run()
{
    ID="$1" && shift
    while [[ $# -ne 0 ]]; do
        local DOCKER_ARGS+=("$1")
        shift
    done
    docker exec \
        -e GOURCE_SECONDS_PER_DAY="0.1" \
        -e GOURCE_TIME_SCALE="2.0" \
        -e FPS="25" \
        -e VIDEO_RESOLUTION="480p" \
        "${DOCKER_ARGS[@]}" \
        envisaged-redux \
        bash /visualization/runtime/entrypoint.sh
    local RESULT=$(sha512sum /workvol/video/output.mp4 | awk '{ print $1 }')
    if [ "${SAVE}" = "1" ]; then
        cp /workvol/video/output.mp4 /hostdir/v_${ID}.mp4
        echo "${RESULT}" >> /hostdir/metadata
    else
        # Check 512 sum matches
        local EXPECTED=$(awk "NR==${ID}" ${DIR}/metadata)
        if [ "${RESULT}" != "${EXPECTED}" ]; then
            exit 1
        fi
    fi

    docker restart envisaged-redux
}


# Set up git test repo
GIT_PARENT_DIR="/workvol/git_sandbox"
mkdir -p ${GIT_PARENT_DIR}
echo "Initializing Git Test Sandbox..."
${DIR}/git_testbed.sh ${GIT_PARENT_DIR} > /dev/null 2>&1


# Unit tests
echo "Starting test"
bats ${DIR}/gource_arg_parse.bats

# Integration tests
# Canceled until further notice.

# Set up environment
# mkdir -p /workvol/video
# ln -sf git_sandbox/repo1 /workvol/git_repo
# set -x

# Init Condition
# integration_run 1

# FPS
# integration_run 2 -e FPS="25"
# integration_run 3 -e FPS="30"
# integration_run 4 -e FPS="60"

# Video Resolution & Borders

# integration_run 5 -e VIDEO_RESOLUTION="480p" 
# integration_run 6 -e VIDEO_RESOLUTION="720p" 
# integration_run 7 -e VIDEO_RESOLUTION="1080p" 
# integration_run 8 -e VIDEO_RESOLUTION="1440p" 
# integration_run 9 -e VIDEO_RESOLUTION="2160p" 

# integration_run 10 -e VIDEO_RESOLUTION="480p" -e TEMPLATE="border"
# integration_run 11 -e VIDEO_RESOLUTION="720p" -e TEMPLATE="border"
# integration_run 12 -e VIDEO_RESOLUTION="1080p" -e TEMPLATE="border" 
# integration_run 13 -e VIDEO_RESOLUTION="1440p" -e TEMPLATE="border" 
# integration_run 14 -e VIDEO_RESOLUTION="2160p" -e TEMPLATE="border" 
