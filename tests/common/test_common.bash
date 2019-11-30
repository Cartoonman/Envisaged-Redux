#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: MIT



integration_run_alt()
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
        echo "${RESULT}" >> /hostdir/cmd_test_data.txt
    else
        # Check 512 sum matches
        local EXPECTED=$(awk "NR==${ID}" ${DIR}/cmd_test_data.txt)
        if [ "${RESULT}" != "${EXPECTED}" ]; then
            exit 1
        fi
    fi

    docker restart envisaged-redux
}