#!/usr/bin/env bats

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

load common/bats_common


@test "Test Error Handling" {
    export COUNT=1

    entrypoint_failure_run RUNTIME_TEMPLATE="nonexistant_template"
    entrypoint_failure_run GOURCE_MAX_FILES="this_isnt_a_number"
    entrypoint_failure_run GOURCE_AUTO_SKIP_SECONDS="-5000"
    entrypoint_failure_run template="border" GOURCE_AUTO_SKIP_SECONDS="-5000"
    entrypoint_failure_run RENDER_FPS=100
    entrypoint_failure_run template="border" RENDER_FPS=100
    entrypoint_failure_run RENDER_VIDEO_RESOLUTION="4k"
    entrypoint_failure_run RUNTIME_TEMPLATE="border" RENDER_VIDEO_RESOLUTION="4k"
    entrypoint_failure_run PREVIEW_SLOWDOWN_FACTOR=1000 RENDER_FPS=25 RUNTIME_LIVE_PREVIEW=1
}

@test "Test Error Handling - Bad Logo" {
    export COUNT=1

    head -c 10000 /dev/null > "${ER_ROOT_DIRECTORY}"/logo.image
    entrypoint_failure_run
    entrypoint_failure_run TEST
    entrypoint_failure_run NO_RUN
    entrypoint_failure_run TEST NO_RUN
    entrypoint_failure_run template="border"
    entrypoint_failure_run RENDER_FPS=100
    rm "${ER_ROOT_DIRECTORY}"/logo.image
}

@test "Test Error Handling - No Repo" {
    export COUNT=1

    mv "${ER_ROOT_DIRECTORY}"/git_repo "${ER_ROOT_DIRECTORY}"/old_git_repo
    entrypoint_failure_run
    entrypoint_failure_run TEST
    entrypoint_failure_run NO_RUN
    entrypoint_failure_run TEST NO_RUN
    entrypoint_failure_run template="border"
    entrypoint_failure_run RENDER_FPS=100
    mv "${ER_ROOT_DIRECTORY}"/old_git_repo "${ER_ROOT_DIRECTORY}"/git_repo
}

