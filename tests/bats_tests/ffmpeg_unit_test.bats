#!/usr/bin/env bats

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

load common/bats_common


@test "Test Invert Colors" {
    ffmpeg_flags_test=("bash" "-c" "source /visualization/runtime/common/common.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${INVERT_FILTER}\";")
    output=$(export INVERT_COLORS=0; "${ffmpeg_flags_test[@]}")
    assert_equal "$output" ""
    output=$(export INVERT_COLORS=1; "${ffmpeg_flags_test[@]}")
    assert_equal "$output" ",lutrgb=r=negval:g=negval:b=negval"
}

@test "Test Logo" {
    ffmpeg_flags_prim_map_label=("bash" "-c" "source /visualization/runtime/common/common.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${PRIMARY_MAP_LABEL}\";")
    ffmpeg_flags_logo_filter_graph=("bash" "-c" "source /visualization/runtime/common/common.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${LOGO_FILTER_GRAPH}\";")
    ffmpeg_flags_status=("bash" "-c" "source /visualization/runtime/common/common.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${?}\";")
    output=$("${ffmpeg_flags_prim_map_label[@]}")
    assert_equal "$output" "[default]"
    output=$("${ffmpeg_flags_logo_filter_graph[@]}")
    assert_equal "$output" ""

    refute [ "$(export LOGO=/path/to/logo.image; "${ffmpeg_flags_status[@]}")" = "0" ]
    assert [ "$(export LOGO=/path/to/logo.image; export LOGO_FFMPEG_LABEL=[1:v]; "${ffmpeg_flags_status[@]}")" = "0" ]

    output=$(export LOGO=/path/to/logo.image; export LOGO_FFMPEG_LABEL=[1:v]; "${ffmpeg_flags_prim_map_label[@]}")
    assert_equal "$output" "[with_logo]"
    output=$(export LOGO=/path/to/logo.image; export LOGO_FFMPEG_LABEL=[1:v]; "${ffmpeg_flags_logo_filter_graph[@]}")
    assert_equal "$output" ";[default][1:v]overlay=main_w-overlay_w-40:main_h-overlay_h-40[with_logo]"
}


@test "Test Preview" {
    ffmpeg_flags_lp_fps=("bash" "-c" "source /visualization/runtime/common/common.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${LP_FPS}\";")
    ffmpeg_flags_live_prev_split=("bash" "-c" "source /visualization/runtime/common/common.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${LIVE_PREVIEW_SPLITTER}\";")
    ffmpeg_flags_prim_map_label=("bash" "-c" "source /visualization/runtime/common/common.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${PRIMARY_MAP_LABEL}\";")
    ffmpeg_flags_live_prev_args=("bash" "-c" "source /visualization/runtime/common/common.bash; gen_ffmpeg_flags > /dev/null 2>&1; echo \"\${LIVE_PREVIEW_ARGS}\";")

    
    output=$("${ffmpeg_flags_lp_fps[@]}")
    assert_equal "$output" ""
    output=$("${ffmpeg_flags_live_prev_split[@]}")
    assert_equal "$output" ""
    output=$("${ffmpeg_flags_prim_map_label[@]}")
    assert_equal "$output" "[default]"
    output=$("${ffmpeg_flags_live_prev_args[@]}")
    assert_equal "$output" ""
    
    output=$(export LIVE_PREVIEW=1; "${ffmpeg_flags_lp_fps[@]}")
    assert_equal "$output" "30"
    output=$(export LIVE_PREVIEW=1; "${ffmpeg_flags_live_prev_split[@]}")
    assert_equal "$output" ";[default]split[original_feed][time_scaler]; \
            [time_scaler]setpts=1*PTS[live_preview]"
    output=$(export LIVE_PREVIEW=1; "${ffmpeg_flags_prim_map_label[@]}")
    assert_equal "$output" "[original_feed]"
    output=$(export LIVE_PREVIEW=1; "${ffmpeg_flags_live_prev_args[@]}")
    assert_equal "$output" " -map [live_preview] -c:v libx264 -pix_fmt yuv420p -maxrate 40M -bufsize 5M \
            -profile:v high -level:v 5.2 -y -r 30 -preset ultrafast -crf 1 \
            -tune zerolatency -x264-params keyint=90:min-keyint=30 \
            -vsync vfr -hls_flags independent_segments+delete_segments -hls_allow_cache 1 \
            -hls_time 1 -hls_list_size 10 -start_number 0 ./html/preview.m3u8"

    output=$(export LIVE_PREVIEW=1; export PREVIEW_SLOWDOWN_FACTOR=3; "${ffmpeg_flags_lp_fps[@]}")
    assert_equal "$output" "10"
    output=$(export LIVE_PREVIEW=1; export PREVIEW_SLOWDOWN_FACTOR=3; "${ffmpeg_flags_live_prev_split[@]}")
    assert_equal "$output" ";[default]split[original_feed][time_scaler]; \
            [time_scaler]setpts=3*PTS[live_preview]"
    output=$(export LIVE_PREVIEW=1; export PREVIEW_SLOWDOWN_FACTOR=3; "${ffmpeg_flags_prim_map_label[@]}")
    assert_equal "$output" "[original_feed]"
    output=$(export LIVE_PREVIEW=1; export PREVIEW_SLOWDOWN_FACTOR=3; "${ffmpeg_flags_live_prev_args[@]}")
    assert_equal "$output" " -map [live_preview] -c:v libx264 -pix_fmt yuv420p -maxrate 40M -bufsize 5M \
            -profile:v high -level:v 5.2 -y -r 10 -preset ultrafast -crf 1 \
            -tune zerolatency -x264-params keyint=30:min-keyint=10 \
            -vsync vfr -hls_flags independent_segments+delete_segments -hls_allow_cache 1 \
            -hls_time 1 -hls_list_size 10 -start_number 0 ./html/preview.m3u8"
}