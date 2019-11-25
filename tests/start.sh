#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker volume create ev-test-volume
docker run --rm -it \
    --name test-envisaged-redux \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ev-test-volume:/workvol \
    -v ${DIR}/../:/workdir:ro \
    cartoonman/test-envisaged-redux:latest \
    bash /workdir/tests/test.sh \
    cartoonman/envisaged-redux:latest
docker volume rm ev-test-volume