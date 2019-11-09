#!/bin/bash

# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: MIT

function print_help 
{
    echo "Args:"
    echo "  --git-repo-dir [absolute/path/to/repo(s)_dir]       Required"
    echo "          The git repo (or directory of git repos) you want gource"
    echo "          to render."
    echo ""
    echo "  --caption-file [absolute/path/to/caption_file]      Optional"
    echo "          The path to a caption file to be used by gource for displaying"
    echo "          captions during the video at predefined timestamps."
    echo ""
    echo "  --avatars-dir  [absolute/path/to/avatars_dir]       Optional"
    echo "          A directory of images with filenames matching that of "
    echo "          users in the git history."
    echo ""
    echo "  --logo-file    [absolute/path/to/logo_image]        Optional"
    echo "          A logo image file to be rendered in the video."
    echo ""
    echo "  Other args will be passed through to docker run command.    "
    echo "          e.g. -e H265_CRF=\"0\" "
}


function parse_args 
{
    ARGS=""
    while [[ $# -gt 0 ]]; do
        k="$1"

        case $k in 
            --git-repo-dir)
                GIT_REPO_DIR=$2
                shift
            ;;
            --caption-file)
                CAPTION_URI="--mount type=bind,source=$2,target=/visualization/captions.txt,readonly"
                shift
            ;;
            --avatars-dir)
                AVATARS_URI="--mount type=bind,source=$2,target=/visualization/avatars,readonly"
                shift
            ;;
            --logo-file)
                LOGO_URI="--mount type=bind,source=$2,target=/visualization/logo.image,readonly"
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
                ARGS="${ARGS} $1"
            ;;
        esac
        shift
    done
}