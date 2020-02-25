#!/usr/bin/env bats

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

load common/bats_common


@test "Test Invert Colors" {
    ffmpeg_flags_test=("bash" "-c" "source "${ER_ROOT_DIRECTORY}"/runtime/common/common_templates.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${invert_filter}\";")
    output="$(export RENDER_INVERT_COLORS=0; "${ffmpeg_flags_test[@]}")"
    assert_equal "$output" ""
    output="$(export RENDER_INVERT_COLORS=1; "${ffmpeg_flags_test[@]}")"
    assert_equal "$output" ",lutrgb=r=negval:g=negval:b=negval"
}

@test "Test Logo" {
    ffmpeg_flags_prim_map_label=("bash" "-c" "source "${ER_ROOT_DIRECTORY}"/runtime/common/common_templates.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${primary_map_label}\";")
    ffmpeg_flags_logo_filter_graph=("bash" "-c" "source "${ER_ROOT_DIRECTORY}"/runtime/common/common_templates.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${logo_filter_graph}\";")
    ffmpeg_flags_status=("bash" "-c" "source "${ER_ROOT_DIRECTORY}"/runtime/common/common_templates.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${?}\";")
    output="$("${ffmpeg_flags_prim_map_label[@]}")"
    assert_equal "$output" "[default]"
    output="$("${ffmpeg_flags_logo_filter_graph[@]}")"
    assert_equal "$output" ""

    refute [ "$(declare -grix RT_LOGO=1; "${ffmpeg_flags_status[@]}")" = "0" ]
    assert [ "$(declare -grix RT_LOGO=1; export logo_ffmpeg_label=[1:v]; "${ffmpeg_flags_status[@]}")" = "0" ]

    output="$(declare -grix RT_LOGO=1; export logo_ffmpeg_label=[1:v]; "${ffmpeg_flags_prim_map_label[@]}")"
    assert_equal "$output" "[with_logo]"
    output="$(declare -grix RT_LOGO=1; export logo_ffmpeg_label=[1:v]; "${ffmpeg_flags_logo_filter_graph[@]}")"
    assert_equal "$output" ";[default][1:v]overlay=main_w-overlay_w-40:main_h-overlay_h-40[with_logo]"
}


@test "Test Preview" {
    ffmpeg_flags_live_prev_split=("bash" "-c" "source "${ER_ROOT_DIRECTORY}"/runtime/common/common_templates.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${live_preview_splitter}\";")
    ffmpeg_flags_prim_map_label=("bash" "-c" "source "${ER_ROOT_DIRECTORY}"/runtime/common/common_templates.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${primary_map_label}\";")
    ffmpeg_flags_live_prev_args=("bash" "-c" "source "${ER_ROOT_DIRECTORY}"/runtime/common/common_templates.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${live_preview_args[@]}\";")


    output="$("${ffmpeg_flags_live_prev_split[@]}")"
    assert_equal "$output" ""
    output="$("${ffmpeg_flags_prim_map_label[@]}")"
    assert_equal "$output" "[default]"
    output="$("${ffmpeg_flags_live_prev_args[@]}")"
    assert_equal "$output" ""

    output=$(declare -grix RT_LIVE_PREVIEW=1; "${ffmpeg_flags_live_prev_split[@]}")
    assert_equal "$output" ";[default]split[original_feed][time_scaler];[time_scaler]setpts=1*PTS[live_preview]"
    output="$(declare -grix RT_LIVE_PREVIEW=1; "${ffmpeg_flags_prim_map_label[@]}")"
    assert_equal "$output" "[original_feed]"
    output="$(declare -grix RT_LIVE_PREVIEW=1; "${ffmpeg_flags_live_prev_args[@]}")"
    assert_equal "$output" "-map [live_preview] -c:v libx264 -pix_fmt yuv420p -maxrate 40M -bufsize 5M -profile:v high -level:v 5.2 -y -r 30 -preset ultrafast -crf 1 -tune zerolatency -x264-params keyint=90:min-keyint=30 -vsync vfr -hls_flags independent_segments+delete_segments -hls_allow_cache 1 -hls_time 1 -hls_list_size 10 -start_number 0 ./html/preview.m3u8"

    output="$(declare -grix RT_LIVE_PREVIEW=1; export PREVIEW_SLOWDOWN_FACTOR=3; "${ffmpeg_flags_live_prev_split[@]}")"
    assert_equal "$output" ";[default]split[original_feed][time_scaler];[time_scaler]setpts=3*PTS[live_preview]"
    output="$(declare -grix RT_LIVE_PREVIEW=1; export PREVIEW_SLOWDOWN_FACTOR=3; "${ffmpeg_flags_prim_map_label[@]}")"
    assert_equal "$output" "[original_feed]"
    output="$(declare -grix RT_LIVE_PREVIEW=1; export PREVIEW_SLOWDOWN_FACTOR=3; "${ffmpeg_flags_live_prev_args[@]}")"
    assert_equal "$output" "-map [live_preview] -c:v libx264 -pix_fmt yuv420p -maxrate 40M -bufsize 5M -profile:v high -level:v 5.2 -y -r 10 -preset ultrafast -crf 1 -tune zerolatency -x264-params keyint=30:min-keyint=10 -vsync vfr -hls_flags independent_segments+delete_segments -hls_allow_cache 1 -hls_time 1 -hls_list_size 10 -start_number 0 ./html/preview.m3u8"
}

@test "Test Profile & Level" {
    ffmpeg_profile_args=("bash" "-c" "source "${ER_ROOT_DIRECTORY}"/runtime/common/common_templates.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${ffmpeg_profile[@]}\";")
    ffmpeg_level_args=("bash" "-c" "source "${ER_ROOT_DIRECTORY}"/runtime/common/common_templates.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${ffmpeg_level[@]}\";")


    output="$("${ffmpeg_profile_args[@]}")"
    assert_equal "$output" ""
    output="$("${ffmpeg_level_args[@]}")"
    assert_equal "$output" ""

    output="$(declare -grx RENDER_PROFILE="baseline"; "${ffmpeg_profile_args[@]}")"
    assert_equal "$output" "-profile:v baseline"
    output="$(declare -grx RENDER_LEVEL=5.1; "${ffmpeg_level_args[@]}")"
    assert_equal "$output" "-level 5.1"
    output="$(declare -grx RENDER_LEVEL=4.0; declare -grx RENDER_PROFILE="main"; "${ffmpeg_profile_args[@]}")"
    assert_equal "$output" "-profile:v main"
    output="$(declare -grx RENDER_LEVEL=4.0; declare -grx RENDER_PROFILE="main"; "${ffmpeg_level_args[@]}")"
    assert_equal "$output" "-level 4.0"

}

@test "Test Codec" {
    ffmpeg_codec=("bash" "-c" "source "${ER_ROOT_DIRECTORY}"/runtime/common/common_templates.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${ffmpeg_codec[@]}\";")

    output="$("${ffmpeg_codec[@]}")"
    assert_equal "$output" "libx264"

    output="$(declare -grx RENDER_CODEC="h265"; "${ffmpeg_codec[@]}")"
    assert_equal "$output" "libx265"
    output="$(declare -grx RENDER_CODEC="h264"; "${ffmpeg_codec[@]}")"
    assert_equal "$output" "libx264"

}