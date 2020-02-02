#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH

NUM_TESTS=$(wc -l ${CUR_DIR_PATH}/../test_data/cmd_test_data.txt | awk '{ print $1 }')
BASELINE=${1:-1}
X=1
INT_CMDS=$(grep integration_run ${CUR_DIR_PATH}/../bats_tests/integration_args.bats | awk '{$1=$1};1')
SAVEIFS=$IFS && IFS=$'\n' && INT_CMDS=($INT_CMDS) && IFS=$SAVEIFS

while [ $X -le ${NUM_TESTS} ]; do
    echo "--------$X-[${INT_CMDS[$(($X - 1 ))]}]--------"
    wdiff -n -w $'\033[30;41m' -x $'\033[0m' -y $'\033[30;42m' -z $'\033[0m' <(awk "NR==${BASELINE}" ${CUR_DIR_PATH}/../test_data/cmd_test_data.txt) <(awk "NR==$X" ${CUR_DIR_PATH}/../test_data/cmd_test_data.txt)
    echo ""
    (( ++X ))
done
