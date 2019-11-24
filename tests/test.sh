#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: MIT

# Entry Point into testing.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. ${DIR}/test_common.bash

IMAGES=$(docker images --format '{{.Repository}}:{{.Tag}}' | sort | grep ${IMAGE_NAME} | grep -v -e '<none>')
SAVEIFS=${IFS} && IFS=$'\n' && IMAGES=(${IMAGES}) && IFS=${SAVEIFS}
if [ ${#IMAGES[@]} -eq 0 ]; then
    echo "No Image for ${IMAGE_NAME} exists. Cannot run tests."
    exit 1
elif [ ${#IMAGES[@]} -gt 1 ]; then
    PS3="More than one image for ${IMAGE_NAME} exists. Select which one to perform test on (number choice): "
    select img in "${IMAGES[@]}"
    do
        IMAGE=${img}
        break
    done
else
    IMAGE="${IMAGES[@]}"
fi




# Test setup (get repos?)


# Start test container
docker run --rm -d \
    -p 8080:80 \
    --name ${IMAGE_NAME} \
    -v ~/mnt/GitHub:/visualization/git_repo:ro \
    ${IMAGE} \
    TEST


test=$(docker exec -t ${IMAGE_NAME} bash -c 'echo "hello there"' | tr -d '\r')
echo "$test"

bats ${DIR}/gource_arg_parse.bats


# Stop test container
docker stop ${IMAGE_NAME}

