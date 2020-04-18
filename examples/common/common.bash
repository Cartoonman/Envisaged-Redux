#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

print_help()
{
    cat < "${CUR_DIR_PATH}/args.txt"
}
readonly -f print_help

parse_args()
{
    args=()
    while (( $# > 0 )); do
        key="$1"

        case ${key} in
            --vcs-source-dir)
                vcs_source_uri=("--mount" "type=bind,src=$2,dst=/visualization/resources/vcs_source,readonly")
                shift
                ;;
            --custom-log)
                custom_log_uri=("--mount" "type=bind,src=$2,dst=/visualization/resources/gource.log,readonly")
                shift
                ;;
            --log-output-dir)
                log_output_uri=("--mount" "type=bind,src=$2,dst=/visualization/output")
                shift
                ;;
            --caption-file)
                caption_uri=("--mount" "type=bind,src=$2,dst=/visualization/resources/captions.txt,readonly")
                shift
                ;;
            --avatars-dir)
                avatars_uri=("--mount" "type=bind,src=$2,dst=/visualization/resources/avatars,readonly")
                shift
                ;;
            --logo-file)
                logo_uri=("--mount" "type=bind,src=$2,dst=/visualization/resources/logo.image,readonly")
                shift
                ;;
            --background-image-file)
                background_image_uri=("--mount" "type=bind,src=$2,dst=/visualization/resources/background.image,readonly")
                shift
                ;;
            --default-user-image-file)
                default_user_image_uri=("--mount" "type=bind,src=$2,dst=/visualization/resources/default_user.image,readonly")
                shift
                ;;
            --font-file)
                font_file_uri=("--mount" "type=bind,src=$2,dst=/visualization/resources/font,readonly")
                shift
                ;;
            --video-output-dir)
                local_output_uri=("--mount" "type=bind,src=$2,dst=/visualization/video")
                shift
                ;;
            -h|--help)
                print_help
                exit 1
                ;;
            *)
                args+=("$1")
                ;;
        esac
        shift
    done
    return 0
}
readonly -f print_help

env_vars_declare()
{
    env_vars=()
    while [[ $# -gt 0 ]]; do
        env_vars+=("-e")
        env_vars+=("$1=$2")
        shift 2
    done
    return 0
}
readonly -f env_vars_declare