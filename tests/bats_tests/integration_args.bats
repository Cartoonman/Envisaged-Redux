#!/usr/bin/env bats

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

load common/bats_common


@test "Test Args" {
    export COUNT=1
    # Baseline
    integration_run 
    integration_run RUNTIME_TEMPLATE="border"

    # RENDER_FPS
    integration_run RENDER_FPS="25"
    integration_run RENDER_FPS="30"
    integration_run RENDER_FPS="60"

    # Encoder Settings
    integration_run RENDER_H265_PRESET="ultrafast"
    integration_run RENDER_H265_CRF=51
    integration_run RENDER_H265_PRESET="ultrafast" RENDER_H265_CRF=51

    # Video Resolution & Border
    integration_run RENDER_VIDEO_RESOLUTION="480p" 
    integration_run RENDER_VIDEO_RESOLUTION="720p" 
    integration_run RENDER_VIDEO_RESOLUTION="1080p" 
    integration_run RENDER_VIDEO_RESOLUTION="1440p" 
    integration_run RENDER_VIDEO_RESOLUTION="2160p" 
    integration_run RUNTIME_TEMPLATE="border" RENDER_VIDEO_RESOLUTION="480p"
    integration_run RUNTIME_TEMPLATE="border" RENDER_VIDEO_RESOLUTION="720p"
    integration_run RUNTIME_TEMPLATE="border" RENDER_VIDEO_RESOLUTION="1080p" 
    integration_run RUNTIME_TEMPLATE="border" RENDER_VIDEO_RESOLUTION="1440p" 
    integration_run RUNTIME_TEMPLATE="border" RENDER_VIDEO_RESOLUTION="2160p" 

    # Live Preview
    integration_run RUNTIME_LIVE_PREVIEW=1
    integration_run RUNTIME_LIVE_PREVIEW=1 PREVIEW_SLOWDOWN_FACTOR=9
    integration_run RUNTIME_TEMPLATE="border" RUNTIME_LIVE_PREVIEW=1
    integration_run RUNTIME_TEMPLATE="border" RUNTIME_LIVE_PREVIEW=1 PREVIEW_SLOWDOWN_FACTOR=9

    # Invert Colors
    integration_run RENDER_INVERT_COLORS=0
    integration_run RENDER_INVERT_COLORS=1
    integration_run RUNTIME_TEMPLATE="border" RENDER_INVERT_COLORS=0
    integration_run RUNTIME_TEMPLATE="border" RENDER_INVERT_COLORS=1

    # Profile & Level
    integration_run RENDER_LEVEL="4.0"
    integration_run RENDER_PROFILE="main"
    integration_run RENDER_PROFILE="baseline" RENDER_LEVEL="3.0"
    integration_run RUNTIME_TEMPLATE="border" RENDER_LEVEL="4.0"
    integration_run RUNTIME_TEMPLATE="border" RENDER_PROFILE="main"
    integration_run RUNTIME_TEMPLATE="border" RENDER_PROFILE="baseline" RENDER_LEVEL="3.0"

    # Codec
    integration_run RENDER_CODEC="h264"
    integration_run RENDER_CODEC="h265"
    integration_run RUNTIME_TEMPLATE="border" RENDER_CODEC="h264"
    integration_run RUNTIME_TEMPLATE="border" RENDER_CODEC="h265"

    # Codec Options
    integration_run RENDER_CODEC="h264" RENDER_H264_PRESET="veryfast" RENDER_H264_CRF="51"
    integration_run RUNTIME_TEMPLATE="border" RENDER_CODEC="h265" RENDER_H265_CRF="1" RENDER_H265_PRESET="veryslow"

    # Verbosity
    integration_run RENDER_VERBOSE="1"
    integration_run RUNTIME_TEMPLATE="border" RENDER_VERBOSE="1"

    # Border Template Specific Testing
    integration_run RUNTIME_TEMPLATE="border" GOURCE_FONT_SIZE="55" GOURCE_FONT_COLOR="0F0F0F" GOURCE_SHOW_KEY="1"
    integration_run RUNTIME_TEMPLATE="border" GOURCE_BORDER_TITLE_SIZE="90" GOURCE_BORDER_DATE_SIZE="91" \
        GOURCE_BORDER_TITLE_COLOR="ABCDEF" GOURCE_BORDER_DATE_COLOR="FEDCBA"


    (( SAVE == 1 )) && skip || :
}

