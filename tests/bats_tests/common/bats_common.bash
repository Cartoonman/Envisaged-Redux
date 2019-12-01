#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${DIR}/helpers/output.bash"
source "${DIR}/helpers/error.bash"
source "${DIR}/helpers/lang.bash"
source "${DIR}/helpers/assert.bash"


gource_args_test=("bash" "-c"  "source /visualization/runtime/common/common.bash; gen_gource_args; echo \"\${GOURCE_ARG_ARRAY[@]}\";")

gource_test_entrypoint_1() {
    local -r TYPE="$1" 
    shift
    if [ "$TYPE" = "bool" ]; then
        gource_test_bools $@
    elif [ "$TYPE" = "var" ]; then
        gource_test_vars $@
    else 
        fail "Missing Type descriptor."
    fi
}

gource_test_entrypoint_2() {
    local -r TYPE="$1" 
    shift
    if [ "$TYPE" = "bool" ]; then
        gource_test_cond_bools $@
    elif [ "$TYPE" = "var" ]; then
        gource_test_cond_vars $@
    else 
        fail "Missing Type descriptor."
    fi
}

gource_test_vars() {
    local -r VAR_NAME="$1"
    local -r EXPECTED="$2"
    local -r RAND_STR=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9 ' | fold -w 32 | head -n 1)
    local -r TEST1=("${EXPECTED} value")
    local -r TEST2=("${EXPECTED} Multi Word Value")
    local -r TEST4=("${EXPECTED} ${RAND_STR}")
    output=$(export $VAR_NAME="value"; "${gource_args_test[@]}")
    assert_equal "${output}" "${EXPECTED} value"
    output=$(export $VAR_NAME="Multi Word Value"; "${gource_args_test[@]}")
    assert_equal "${output}" "${TEST2[@]}"
    output=$(export $VAR_NAME=""; "${gource_args_test[@]}")
    assert_equal "${output}"  "" 
    output=$(export $VAR_NAME="${RAND_STR}"; "${gource_args_test[@]}")
    assert_equal "${output}" "${TEST4[@]}"
}

gource_test_bools() {
    local -r VAR_NAME="$1"
    local -r EXPECTED="$2"

    output=$(export $VAR_NAME="1"; "${gource_args_test[@]}")
    assert_equal "${output}" "${EXPECTED}"
    output=$(export $VAR_NAME="0"; "${gource_args_test[@]}")
    assert_equal "${output}" ""
    output=$(export $VAR_NAME=""; "${gource_args_test[@]}")
    assert_equal "${output}"  "" 
}

gource_test_cond_vars() {
    local -r VAR_NAME="$1"
    local -r EXPECTED="$2"
    local -r CTRL_VAR="$3"
    local -r CTRL_VAR_KEY="$4"
    local -r CTRL_VAR_VAL="$5"
    local -r TEST1=("$CTRL_VAR_KEY" "$CTRL_VAR_VAL" "${EXPECTED}" "value")
    local -r TEST2=("$CTRL_VAR_KEY" "$CTRL_VAR_VAL" "${EXPECTED}" "Multi Word Value")
    local -r TEST3=("$CTRL_VAR_KEY" "$CTRL_VAR_VAL")
    output=$(export $CTRL_VAR="0"; export $VAR_NAME="value"; "${gource_args_test[@]}")
    assert_equal "${output}" ""
    output=$(export $CTRL_VAR="0"; export $VAR_NAME="Multi Word Value"; "${gource_args_test[@]}")
    assert_equal "${output}" ""
    output=$(export $CTRL_VAR="0"; export $VAR_NAME=""; "${gource_args_test[@]}")
    assert_equal "${output}" ""
    output=$(export $CTRL_VAR=""; export $VAR_NAME="value"; "${gource_args_test[@]}")
    assert_equal "${output}" ""
    output=$(export $CTRL_VAR=""; export $VAR_NAME="Multi Word Value"; "${gource_args_test[@]}")
    assert_equal "${output}" ""
    output=$(export $CTRL_VAR=""; export $VAR_NAME=""; "${gource_args_test[@]}")
    assert_equal "${output}" ""
    output=$(export $CTRL_VAR="1"; export $VAR_NAME="value"; "${gource_args_test[@]}")
    assert_equal "${output}" "$(echo ${TEST1[@]})"
    output=$(export $CTRL_VAR="1"; export $VAR_NAME="Multi Word Value"; "${gource_args_test[@]}")
    assert_equal "${output}" "$(echo ${TEST2[@]})"
    output=$(export $CTRL_VAR="1"; export $VAR_NAME=""; "${gource_args_test[@]}")
    assert_equal "${output}" "$(echo ${TEST3[@]})"
}

gource_test_cond_bools() {
    local -r VAR_NAME="$1"
    local -r EXPECTED="$2"
    local -r CTRL_VAR="$3"
    local -r CTRL_VAR_KEY="$4"
    local -r CTRL_VAR_VAL="$5"
    local -r TEST1=("$CTRL_VAR_KEY" "$CTRL_VAR_VAL" "${EXPECTED}")
    local -r TEST2=("$CTRL_VAR_KEY" "$CTRL_VAR_VAL")
    local -r TEST3=("$CTRL_VAR_KEY" "$CTRL_VAR_VAL")
    output=$(export $CTRL_VAR="0"; export $VAR_NAME="1"; "${gource_args_test[@]}")
    assert_equal "${output}" ""
    output=$(export $CTRL_VAR="0"; export $VAR_NAME="0"; "${gource_args_test[@]}")
    assert_equal "${output}" ""
    output=$(export $CTRL_VAR="0"; export $VAR_NAME=""; "${gource_args_test[@]}")
    assert_equal "${output}" ""
    output=$(export $CTRL_VAR=""; export $VAR_NAME="1"; "${gource_args_test[@]}")
    assert_equal "${output}" ""
    output=$(export $CTRL_VAR=""; export $VAR_NAME="0"; "${gource_args_test[@]}")
    assert_equal "${output}" ""
    output=$(export $CTRL_VAR=""; export $VAR_NAME=""; "${gource_args_test[@]}")
    assert_equal "${output}" ""
    output=$(export $CTRL_VAR="1"; export $VAR_NAME="1"; "${gource_args_test[@]}")
    assert_equal "${output}" "$(echo ${TEST1[@]})"
    output=$(export $CTRL_VAR="1"; export $VAR_NAME="0"; "${gource_args_test[@]}")
    assert_equal "${output}" "$(echo ${TEST2[@]})"
    output=$(export $CTRL_VAR="1"; export $VAR_NAME=""; "${gource_args_test[@]}")
    assert_equal "${output}" "$(echo ${TEST3[@]})"
}

gource_test_avatars() {
    local -r CTRL_VAR="$1"
    local -r CTRL_VAR_KEY="$2"
    local -r CTRL_VAR_VAL="$3"
    local -r TEST1=("$CTRL_VAR_KEY" "$CTRL_VAR_VAL")
    output=$(export $CTRL_VAR="0"; "${gource_args_test[@]}")
    assert_equal "${output}" ""
    output=$(export $CTRL_VAR=""; "${gource_args_test[@]}")
    assert_equal "${output}" ""
    output=$(export $CTRL_VAR="1"; "${gource_args_test[@]}")
    assert_equal "${output}" "$(echo ${TEST1[@]})"
}

integration_run()
{
    while [[ $# -ne 0 ]]; do
        local ENV_ARGS+=("$1")
        shift
    done
    printf "Test ${COUNT}\r" >&3
    local LOG_OUTPUT=$(eval "${ENV_ARGS[@]}" /visualization/runtime/entrypoint.sh TEST NORUN 2>&1)
    [ ! $? -eq 0 ] && echo -e "${LOG_OUTPUT}" && fail "Failure detected on test #${COUNT}"
    if [ "${SAVE}" = "1" ]; then
        printf "\n" >> /visualization/cmd_test_data.txt
    else
        local RESULT=$(cat /visualization/cmd_test_data.txt)
        local EXPECTED=$(awk "NR==${COUNT}" /visualization/tests/test_data/cmd_test_data.txt)
        assert_equal "${RESULT}" "${EXPECTED}" || wdiff -n -w $'\033[30;41m' -x $'\033[0m' -y $'\033[30;42m' -z $'\033[0m' <(echo "${EXPECTED}") <(echo "${RESULT}") || fail "Failure detected on test #${COUNT}"
        rm /visualization/cmd_test_data.txt
    fi
    (( ++COUNT ))
}

repo_run()
{
    while [[ $# -ne 0 ]]; do
        local ENV_ARGS+=("$1")
        shift
    done
    printf "Test ${COUNT}\r" >&3
    local LOG_OUTPUT=$(eval "${ENV_ARGS[@]}" /visualization/runtime/entrypoint.sh TEST NORUN 2>&1)
    [ ! $? -eq 0 ] && echo -e "${LOG_OUTPUT}" && fail "Failure detected on test #${COUNT}"
    if [ "${SAVE}" = "1" ]; then
        cp /visualization/development.log /hostdir/r_"${COUNT}".log
    else
        local RESULT=$(cat /visualization/development.log)
        local EXPECTED=$(cat /visualization/tests/test_data/repo/r_${COUNT}.log)
        assert_equal "${RESULT}" "${EXPECTED}" || wdiff -n -w $'\033[30;41m' -x $'\033[0m' -y $'\033[30;42m' -z $'\033[0m' <(echo "${EXPECTED}") <(echo "${RESULT}") || fail "Failure detected on test #${COUNT}"
        rm /visualization/development.log
    fi
    (( ++COUNT ))
}