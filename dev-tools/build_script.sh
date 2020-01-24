#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH

set -e

test_flag=0

while [[ $# -gt 0 ]]; do
    k="$1"
    case $k in
        --test-args)
            test_flag=1
            ;;
        --)
            test_flag=0
            ;;
        *)
            if (( test_flag == 1 )); then
                test_args+=("$k")
            fi
            ;;
    esac
    shift
done


docker build "$@" ${CUR_DIR_PATH}/../ -t cartoonman/envisaged-redux:latest
docker build "$@" -f ${CUR_DIR_PATH}/../tests/Dockerfile ${CUR_DIR_PATH}/../ -t cartoonman/test-envisaged-redux:latest
${CUR_DIR_PATH}/../tests/scripts/start.sh "${test_args[@]}"