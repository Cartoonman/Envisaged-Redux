#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

# Entry Point into testing.
CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH
set -e
readonly ER_ROOT_DIRECTORY="/visualization"

export SAVE=0
while [[ $# -gt 0 ]]; do
    k="$1"
    case $k in
        -s)
            SAVE=1
        ;;
        --system)
            RUN_SYSTEM_TESTS=1
        ;;
    esac
    shift
done

# Set up git test repo
GIT_PARENT_DIR="${ER_ROOT_DIRECTORY}/git_sandbox"
mkdir -p ${GIT_PARENT_DIR}
echo "---Initializing Git Test Sandbox---"
${CUR_DIR_PATH}/git_testbed.sh ${GIT_PARENT_DIR} > /dev/null 2>&1


# Unit tests
echo "---Starting Unit Tests---"
bats ${CUR_DIR_PATH}/bats_tests/gource_unit_test.bats
bats ${CUR_DIR_PATH}/bats_tests/ffmpeg_unit_test.bats

# Integration tests
echo "---Starting Integration Tests---"


# Test Gource x ffmpeg args


# Set up environment
mkdir -p "${ER_ROOT_DIRECTORY}"/video
ln -sf "${ER_ROOT_DIRECTORY}"/git_sandbox/repo1 "${ER_ROOT_DIRECTORY}"/git_repo

bats ${CUR_DIR_PATH}/bats_tests/entrypoint_test.bats

bats ${CUR_DIR_PATH}/bats_tests/integration_args.bats

[ "${SAVE}" = "1" ] && mv "${ER_ROOT_DIRECTORY}"/cmd_test_data.txt /hostdir/cmd_test_data.txt

bats ${CUR_DIR_PATH}/bats_tests/repo_parse.bats


# System tests
if (( RUN_SYSTEM_TESTS == 1 )); then
    echo "---Starting System Tests---"

    mkdir -p "${ER_ROOT_DIRECTORY}"/video
    bats ${CUR_DIR_PATH}/bats_tests/system_test.bats
fi

echo "---Test Complete---"