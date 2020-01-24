#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH

while [[ $# -gt 0 ]]; do
    k="$1"
    case $k in
        --save)
            HOST_MOUNT="--mount type=bind,source=$2,target=/hostdir"
            ARGS+=('-s')
            shift
            ;;
        --system-test)
            ARGS+=('--system')
            ;;
    esac
    shift
done

docker run --rm -it \
    --name test-envisaged-redux \
    ${HOST_MOUNT} \
    cartoonman/test-envisaged-redux:latest \
    "${ARGS[@]}"
