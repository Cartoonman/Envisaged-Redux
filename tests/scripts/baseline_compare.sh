#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH

num_tests="$(wc -l "${CUR_DIR_PATH}"/../test_data/cmd_test_data.txt | awk '{ print $1 }')"
baseline=${1:-1}
count=1
int_cmds="$(grep integration_run "${CUR_DIR_PATH}"/../bats_tests/integration_args.bats | awk '{$1=$1};1')"
readarray -d $'\n' -t int_cmds <<< "${int_cmds}"

while (( count <= num_tests )); do
    echo "--------${count}-[${int_cmds[$(($count - 1 ))]}]--------"
    wdiff -n -w $'\033[30;41m' -x $'\033[0m' -y $'\033[30;42m' -z $'\033[0m' <(awk "NR==${baseline}" ${CUR_DIR_PATH}/../test_data/cmd_test_data.txt) <(awk "NR==$count" ${CUR_DIR_PATH}/../test_data/cmd_test_data.txt)
    echo ""
    (( ++count ))
done
