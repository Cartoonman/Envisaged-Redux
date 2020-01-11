#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

inc_dir_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${inc_dir_path}/common.bash"
unset inc_dir_path

declare -r XVFB_TIMEOUT=60

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