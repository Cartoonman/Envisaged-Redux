#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -e

docker build "$@" ${CUR_DIR_PATH}/../ -t cartoonman/envisaged-redux:latest
docker build "$@" -f ${CUR_DIR_PATH}/../tests/Dockerfile ${CUR_DIR_PATH}/../ -t cartoonman/test-envisaged-redux:latest
${CUR_DIR_PATH}/../tests/scripts/start.sh