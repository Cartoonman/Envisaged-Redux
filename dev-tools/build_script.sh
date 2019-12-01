#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker build "${@}" ${DIR}/../ -t cartoonman/envisaged-redux:latest
docker build "${@}" -f tests/Dockerfile ${DIR}/../ -t cartoonman/test-envisaged-redux:latest
${DIR}/../tests/scripts/start.sh