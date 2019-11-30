#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

while [[ $# -gt 0 ]]; do
    k="$1"
    case $k in
        --save)
            HOST_MOUNT="--mount type=bind,source=$2,target=/hostdir"
            ARGS+=('-s')
            shift
            ;;
    esac
    shift
done

echo "Initializing Test Environment"

docker run --rm -it \
    --name test-envisaged-redux \
    ${HOST_MOUNT} \
    cartoonman/test-envisaged-redux:latest \
    "${ARGS[@]}"
