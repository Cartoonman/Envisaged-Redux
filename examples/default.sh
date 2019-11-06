#!/bin/bash

# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: MIT
DIR="${BASH_SRC%/*}"
if [[ ! -d  "$DIR" ]]; then DIR="$PWD"; fi

function print_help {
    echo "Args:"
    echo "  --git-repo     [absolute/path/to/repo]              Required"
    echo "  --caption-file [absolute/path/to/caption_file]      Optional"
    echo "  --avatars-dir  [absolute/path/to/avatars_dir]       Optional"
    echo "  --logo-file    [absolute/path/to/logo_image]        Optional"
    echo "  Other args will be passed through to docker run command.    "
    echo "  e.g. -e H265_CRF=\"0\" "
}

ARGS=""
while [[ $# -gt 0 ]]; do
    k="$1"

    case $k in 
        --git-repo)
            GIT_REPO=$2
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

if [ "${GIT_REPO}" = "" ]; then
    echo "No git repo directory specified, using Envisaged-Redux repo..."
    GIT_REPO=$DIR/../
fi

docker run --rm \
-p 8080:80 \
--name envisaged-redux \
-v ${GIT_REPO}:/visualization/git_repo:ro \
${CAPTION_URI} \
${AVATARS_URI} \
${LOGO_URI} \
$ARGS \
envisaged-redux:latest