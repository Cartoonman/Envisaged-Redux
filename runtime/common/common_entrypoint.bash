#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

inc_dir_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${inc_dir_path}/common.bash"
ER_VERSION=$( cat "${inc_dir_path}/../../VERSION" )
unset inc_dir_path

XVFB_TIMEOUT=60
HTTPD_TIMEOUT=15

function print_intro
{
    cat << "EOF"
 _____            _                          _    ____          _
| ____|_ ____   _(_)___  __ _  __ _  ___  __| |  |  _ \ ___  __| |_   ___  __
|  _| | '_ \ \ / / / __|/ _` |/ _` |/ _ \/ _` |  | |_) / _ \/ _` | | | \ \/ /
| |___| | | \ V /| \__ \ (_| | (_| |  __/ (_| |  |  _ <  __/ (_| | |_| |>  <
|_____|_| |_|\_/ |_|___/\__,_|\__, |\___|\__,_|  |_| \_\___|\__,_|\__,_/_/\_\
******************************|___/******************************************
EOF
printf "Version ${ER_VERSION}\n\n"
}
readonly -f print_intro

function parse_args
{
    while [[ $# -gt 0 ]]; do
        local k="$1"
        case $k in
            HOLD)
                log_info "Test mode enabled. Spinning main thread. Run docker stop on container when complete."
                trap 'exit 143' SIGTERM # exit = 128 + 15 (SIGTERM)
                tail -f /dev/null & wait ${!}
                exit 0
                ;;
            TEST)
                export TEST=1
                log_warn "TEST Flag Invoked"
                ;;
            NORUN)
                export NORUN=1
                log_warn "NORUN Flag Invoked"
                ;;
        esac
        shift
    done
}
readonly -f parse_args

function parse_configs
{
    # Check runtime mode.
    echo 0 > /visualization/html/live_preview
    if [ "${ENABLE_LIVE_PREVIEW}" = "1" ]; then
        export LIVE_PREVIEW=1
        echo 1 > /visualization/html/live_preview
    fi

    # Check for video saving mode
    if [ -d /visualization/video ]; then
        export USE_LOCAL_OUTPUT=1
    else
        mkdir -p /visualization/video
    fi

    # Check which gource release is chosen
    if [ "${USE_GOURCE_NIGHTLY}" = "1" ]; then
        export GOURCE_EXEC='gource_nightly'
        log_notice "Using $(${GOURCE_EXEC} -h | head -n 1) Nightly Release"
        export USE_NIGHTLY=1
    else
        export GOURCE_EXEC='gource'
        log_info "Using $(${GOURCE_EXEC} -h | head -n 1) Stable Release "
    fi

    # Check for avatar directory mount.
    if [ -d /visualization/avatars ]; then
        log_info "Using avatars directory"
        export USE_AVATARS=1
    fi

    # Check for captions
    if [ -f /visualization/captions.txt ]; then
        log_info "Using captions file"
        export USE_CAPTIONS=1
    fi

    # Check for logo
    if [ -f /visualization/logo.image ]; then
        log_notice "Possible logo file detected. Attempting to transform..."
        set -e
        convert -geometry x160 /visualization/logo.image /visualization/logo_txfrmed.image
        set +e
        log_success "Success. Using logo file"
        export LOGO=" -i /visualization/logo_txfrmed.image "
    fi


    # Check if repo exists
    if [ ! -d /visualization/git_repo ]
    then
        log_error "Error: git repo not found: /visualization/git_repo does not exist."
        exit 1
    fi
}
readonly -f parse_configs