#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH

while (( $# > 0 )); do
    k="$1"
    case $k in
        --save)
            host_mount=("--mount" "type=bind,source=$2,target=/hostdir")
            args+=('-s')
            shift
            ;;
        --system-test)
            args+=('--system')
            ;;
    esac
    shift
done

docker run --rm -t \
    --name test-envisaged-redux \
    "${host_mount[@]}" \
    cartoonman/test-envisaged-redux:latest \
    "${args[@]}"
