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


echo "Initializing Container under Test"
docker run --rm -d \
    -p 8080:80 \
    --name envisaged-redux \
    --mount type=volume,source=ev-test-volume,target=/visualization \
    cartoonman/envisaged-redux:latest \
    TEST

echo "Initializing Test Environment"

docker run --rm -it \
    --name test-envisaged-redux \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --mount type=volume,source=ev-test-volume,target=/workvol \
    ${HOST_MOUNT} \
    cartoonman/test-envisaged-redux:latest \
    bash /workvol/tests/test.sh "${ARGS[@]}"

docker stop envisaged-redux

docker volume rm ev-test-volume
