#!/bin/bash

# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: MIT
DIR="${BASH_SRC%/*}"
if [[ ! -d  "$DIR" ]]; then DIR="$PWD"; fi

function print_help {
    echo "Args:"
    echo "  --git-repo [absolute_path_to_repo]                Required"
    echo "  --caption-file [absolute_path_to_caption_file]    Optional"
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
$ARGS \
envisaged-redux:latest