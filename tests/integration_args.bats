#!/usr/bin/env bats

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: MIT

load test_common


@test "Integration Tests" {
    COUNT=1
    # Init Condition
    integration_run 

    # FPS
    integration_run FPS="25"
    integration_run FPS="30"
    integration_run FPS="60"

    # Video Resolution & Border
    integration_run VIDEO_RESOLUTION="480p" 
    integration_run VIDEO_RESOLUTION="720p" 
    integration_run VIDEO_RESOLUTION="1080p" 
    integration_run VIDEO_RESOLUTION="1440p" 
    integration_run VIDEO_RESOLUTION="2160p" 
    integration_run VIDEO_RESOLUTION="480p" TEMPLATE="border"
    integration_run VIDEO_RESOLUTION="720p" TEMPLATE="border"
    integration_run VIDEO_RESOLUTION="1080p" TEMPLATE="border" 
    integration_run VIDEO_RESOLUTION="1440p" TEMPLATE="border" 
    integration_run VIDEO_RESOLUTION="2160p" TEMPLATE="border" 
}

