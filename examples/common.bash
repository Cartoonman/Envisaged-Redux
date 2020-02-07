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
    declare -ag args=()
    while (( $# > 0 )); do
        key="$1"

        case ${key} in
            --git-repo-dir)
                git_repo_uri=("--mount" "type=bind,src=$2,dst=/visualization/git_repo,readonly")
                shift
                ;;
            --caption-file)
                caption_uri=("--mount" "type=bind,src=$2,dst=/visualization/captions.txt,readonly")
                shift
                ;;
            --avatars-dir)
                avatars_uri=("--mount" "type=bind,src=$2,dst=/visualization/avatars,readonly")
                shift
                ;;
            --logo-file)
                logo_uri=("--mount" "type=bind,src=$2,dst=/visualization/logo.image,readonly")
                shift
                ;;
            --output-dir)
                local_output_uri=("--mount" "type=bind,src=$2,dst=/visualization/video")
                shift
                ;;
            -h)
                print_help
                exit 1
                ;;
            --help)
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
    declare -ga env_vars=()
    while [[ $# -gt 0 ]]; do
        env_vars+=("-e")
        env_vars+=("$1=$2")
        shift 2
    done
    return 0
}
readonly -f env_vars_declare