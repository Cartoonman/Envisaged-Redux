#!/usr/bin/env bats

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

load common/bats_common


@test "Test Gource Args General" {
    gource_test_entrypoint_1 "var" "GOURCE_TITLE" "--title"
    gource_test_entrypoint_1 "var" "GOURCE_CAMERA_MODE" "--camera-mode"
    gource_test_entrypoint_1 "var" "GOURCE_START_DATE" "--start-date"
    gource_test_entrypoint_1 "var" "GOURCE_STOP_DATE" "--stop-date"
    gource_test_entrypoint_1 "var" "GOURCE_START_POSITION" "--start-position"
    gource_test_entrypoint_1 "var" "GOURCE_STOP_POSITION" "--stop-position"
    gource_test_entrypoint_1 "var" "GOURCE_STOP_AT_TIME" "--stop-at-time"
    gource_test_entrypoint_1 "var" "GOURCE_SECONDS_PER_DAY" "--seconds-per-day"
    gource_test_entrypoint_1 "var" "GOURCE_AUTO_SKIP_SECONDS" "--auto-skip-seconds"
    gource_test_entrypoint_1 "var" "GOURCE_TIME_SCALE" "--time-scale"
    gource_test_entrypoint_1 "var" "GOURCE_USER_SCALE" "--user-scale"
    gource_test_entrypoint_1 "var" "GOURCE_MAX_USER_SPEED" "--max-user-speed"
    gource_test_entrypoint_1 "var" "GOURCE_HIDE_ITEMS" "--hide"
    gource_test_entrypoint_1 "var" "GOURCE_FILE_IDLE_TIME" "--file-idle-time"
    gource_test_entrypoint_1 "var" "GOURCE_MAX_FILES" "--max-files"
    gource_test_entrypoint_1 "var" "GOURCE_MAX_FILE_LAG" "--max-file-lag"
    gource_test_entrypoint_1 "var" "GOURCE_FILENAME_TIME" "--filename-time"
    gource_test_entrypoint_1 "var" "GOURCE_FONT_SIZE" "--font-size"
    gource_test_entrypoint_1 "var" "GOURCE_FONT_COLOR" "--font-colour"
    gource_test_entrypoint_1 "var" "GOURCE_BACKGROUND_COLOR" "--background-colour"
    gource_test_entrypoint_1 "var" "GOURCE_DATE_FORMAT" "--date-format"
    gource_test_entrypoint_1 "var" "GOURCE_DIR_DEPTH" "--dir-name-depth"
    gource_test_entrypoint_1 "var" "GOURCE_BLOOM_MULTIPLIER" "--bloom-multiplier"
    gource_test_entrypoint_1 "var" "GOURCE_BLOOM_INTENSITY" "--bloom-intensity"
    gource_test_entrypoint_1 "var" "GOURCE_PADDING" "--padding"
    gource_test_entrypoint_1 "bool" "GOURCE_HIGHLIGHT_ALL_USERS" "--highlight-users"
    gource_test_entrypoint_1 "bool" "GOURCE_MULTI_SAMPLING" "--multi-sampling"
    gource_test_entrypoint_1 "bool" "GOURCE_SHOW_KEY" "--key"
}


@test "Test Gource Args Caption" {
    local -r CTRL_ARGS_STD=("USE_CAPTIONS" "--caption-file" "/visualization/captions.txt")
    gource_test_entrypoint_2 "var" "GOURCE_CAPTION_SIZE" "--caption-size" "${CTRL_ARGS_STD[@]}"
    gource_test_entrypoint_2 "var" "GOURCE_CAPTION_COLOR" "--caption-colour" "${CTRL_ARGS_STD[@]}"
    gource_test_entrypoint_2 "var" "GOURCE_CAPTION_DURATION" "--caption-duration" "${CTRL_ARGS_STD[@]}"
}

@test "Test Gource Args Nightly" {
    local -r CTRL_ARGS_STD=("USE_NIGHTLY")
    gource_test_entrypoint_2 "bool" "GOURCE_FILE_EXT_FALLBACK" "--file-extension-fallback" "${CTRL_ARGS_STD[@]}"
}


@test "Test Gource Args Avatars" {
    local -r CTRL_ARGS_STD=("USE_AVATARS" "--user-image-dir" "/visualization/avatars")
    gource_test_avatars "${CTRL_ARGS_STD[@]}"
}