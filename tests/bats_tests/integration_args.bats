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
    integration_run TEMPLATE="border"

    # FPS
    integration_run FPS="25"
    integration_run FPS="30"
    integration_run FPS="60"

    # Encoder Settings
    integration_run H265_PRESET="ultrafast"
    integration_run H265_CRF=51
    integration_run H265_PRESET="ultrafast" H265_CRF=51

    # Video Resolution & Border
    integration_run VIDEO_RESOLUTION="480p" 
    integration_run VIDEO_RESOLUTION="720p" 
    integration_run VIDEO_RESOLUTION="1080p" 
    integration_run VIDEO_RESOLUTION="1440p" 
    integration_run VIDEO_RESOLUTION="2160p" 
    integration_run TEMPLATE="border" VIDEO_RESOLUTION="480p"
    integration_run TEMPLATE="border" VIDEO_RESOLUTION="720p"
    integration_run TEMPLATE="border" VIDEO_RESOLUTION="1080p" 
    integration_run TEMPLATE="border" VIDEO_RESOLUTION="1440p" 
    integration_run TEMPLATE="border" VIDEO_RESOLUTION="2160p" 

    # Live Preview
    integration_run ENABLE_LIVE_PREVIEW=1
    integration_run ENABLE_LIVE_PREVIEW=1 PREVIEW_SLOWDOWN_FACTOR=9
    integration_run TEMPLATE="border" ENABLE_LIVE_PREVIEW=1
    integration_run TEMPLATE="border" ENABLE_LIVE_PREVIEW=1 PREVIEW_SLOWDOWN_FACTOR=9

    # Invert Colors
    integration_run INVERT_COLORS=0
    integration_run INVERT_COLORS=1
    integration_run TEMPLATE="border" INVERT_COLORS=0
    integration_run TEMPLATE="border" INVERT_COLORS=1

    # Gource Nightly
    integration_run USE_GOURCE_NIGHTLY=0
    integration_run USE_GOURCE_NIGHTLY=1
    integration_run TEMPLATE="border" USE_GOURCE_NIGHTLY=0
    integration_run TEMPLATE="border" USE_GOURCE_NIGHTLY=1



    [ "${SAVE}" = "1" ] && skip || :
}

