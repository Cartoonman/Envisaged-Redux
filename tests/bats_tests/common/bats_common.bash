#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

declare -r CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${CUR_DIR_PATH}/helpers/output.bash"
source "${CUR_DIR_PATH}/helpers/error.bash"
source "${CUR_DIR_PATH}/helpers/lang.bash"
source "${CUR_DIR_PATH}/helpers/assert.bash"


gource_args_test=("bash" "-c"  "source /visualization/runtime/common/common_templates.bash; gen_gource_args; echo \"\${gource_arg_array[@]}\";")

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
    local -r expected_result="$2"
    local -r RAND_STR=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9 ' | fold -w 32 | head -n 1)
    local -r TEST1=("${expected_result} value")
    local -r TEST2=("${expected_result} Multi Word Value")
    local -r TEST4=("${expected_result} ${RAND_STR}")
    output=$(export $VAR_NAME="value"; "${gource_args_test[@]}")
    assert_equal "${output}" "${expected_result} value"
    output=$(export $VAR_NAME="Multi Word Value"; "${gource_args_test[@]}")
    assert_equal "${output}" "${TEST2[@]}"
    output=$(export $VAR_NAME=""; "${gource_args_test[@]}")
    assert_equal "${output}"  "" 
    output=$(export $VAR_NAME="${RAND_STR}"; "${gource_args_test[@]}")
    assert_equal "${output}" "${TEST4[@]}"
}

gource_test_bools() {
    local -r VAR_NAME="$1"
    local -r expected_result="$2"

    output=$(export $VAR_NAME="1"; "${gource_args_test[@]}")
    assert_equal "${output}" "${expected_result}"
    output=$(export $VAR_NAME="0"; "${gource_args_test[@]}")
    assert_equal "${output}" ""
    output=$(export $VAR_NAME=""; "${gource_args_test[@]}")
    assert_equal "${output}"  "" 
}

gource_test_cond_vars() {
    local -r VAR_NAME="$1"
    local -r expected_result="$2"
    local -r CTRL_VAR="$3"
    local -r CTRL_VAR_KEY="$4"
    local -r CTRL_VAR_VAL="$5"
    local -r TEST1=("$CTRL_VAR_KEY" "$CTRL_VAR_VAL" "${expected_result}" "value")
    local -r TEST2=("$CTRL_VAR_KEY" "$CTRL_VAR_VAL" "${expected_result}" "Multi Word Value")
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
    local -r expected_result="$2"
    local -r CTRL_VAR="$3"
    local -r CTRL_VAR_KEY="$4"
    local -r CTRL_VAR_VAL="$5"
    local -r TEST1=("$CTRL_VAR_KEY" "$CTRL_VAR_VAL" "${expected_result}")
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
    local log_output=$(eval "${ENV_ARGS[@]}" /visualization/runtime/entrypoint.sh TEST NORUN 2>&1) runtime_exit_code=$?
    [ ! $runtime_exit_code -eq 0 ] && echo -e "${log_output}" && fail "Failure detected on test #${COUNT}"
    if [ "${SAVE}" = "1" ]; then
        printf "\n" >> /visualization/cmd_test_data.txt
    else
        local actual_result=$(cat /visualization/cmd_test_data.txt)
        local expected_result=$(awk "NR==${COUNT}" /visualization/tests/test_data/cmd_test_data.txt)
        assert_equal "${actual_result}" "${expected_result}" || wdiff -n -w $'\033[30;41m' -x $'\033[0m' -y $'\033[30;42m' -z $'\033[0m' <(echo "${expected_result}") <(echo "${actual_result}") || fail "Failure detected on test #${COUNT}"
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
    local log_output=$(eval "${ENV_ARGS[@]}" /visualization/runtime/entrypoint.sh TEST NORUN 2>&1) runtime_exit_code=$?
    [ ! $runtime_exit_code -eq 0 ] && echo -e "${log_output}" && fail "Failure detected on test #${COUNT}"
    if [ "${SAVE}" = "1" ]; then
        cp /visualization/development.log /hostdir/r_"${COUNT}".log
    else
        local actual_result=$(cat /visualization/development.log)
        local expected_result=$(cat /visualization/tests/test_data/repo/r_${COUNT}.log)
        assert_equal "${actual_result}" "${expected_result}" || wdiff -n -w $'\033[30;41m' -x $'\033[0m' -y $'\033[30;42m' -z $'\033[0m' <(echo "${expected_result}") <(echo "${actual_result}") || fail "Failure detected on test #${COUNT}"
        rm /visualization/development.log
    fi
    (( ++COUNT ))
}