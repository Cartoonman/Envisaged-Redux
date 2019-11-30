#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

NUM_TESTS=$(wc -l ${DIR}/cmd_test_data.txt | awk '{ print $1 }')
BASELINE=${1:-1}
X=1
INT_CMDS=$(grep integration_run ${DIR}/bats_tests/integration_args.bats | awk '{$1=$1};1')
SAVEIFS=$IFS && IFS=$'\n' && INT_CMDS=($INT_CMDS) && IFS=$SAVEIFS

while [ $X -le ${NUM_TESTS} ]; do
    echo "--------$X-[${INT_CMDS[$(($X - 1 ))]}]--------"
    wdiff -n -w $'\033[30;41m' -x $'\033[0m' -y $'\033[30;42m' -z $'\033[0m' <(awk "NR==${BASELINE}" ${DIR}/cmd_test_data.txt) <(awk "NR==$X" ${DIR}/cmd_test_data.txt)
    echo ""
    (( ++X ))
done
