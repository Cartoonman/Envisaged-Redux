#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: MIT

source "$(dirname "${BASH_SOURCE[0]}")/helpers/output.bash"
source "$(dirname "${BASH_SOURCE[0]}")/helpers/error.bash"
source "$(dirname "${BASH_SOURCE[0]}")/helpers/lang.bash"
source "$(dirname "${BASH_SOURCE[0]}")/helpers/assert.bash"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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
    eval "${ENV_ARGS[@]}" /visualization/runtime/entrypoint.sh TEST NORUN > /dev/null 2>&1
    if [ "${SAVE}" = "1" ]; then
        printf "\n" >> /visualization/metadata
    else
        # Check 512 sum matches
        local RESULT=$(cat /visualization/metadata)
        local EXPECTED=$(awk "NR==${COUNT}" /visualization/tests/metadata)
        assert_equal "${RESULT}" "${EXPECTED}" || wdiff -3 <(echo "${RESULT}") <(echo "${EXPECTED}") || fail "Failure detected on test #${COUNT}"
        rm /visualization/metadata
    fi
    (( ++COUNT ))
}

integration_run_alt()
{
    ID="$1" && shift
    while [[ $# -ne 0 ]]; do
        local DOCKER_ARGS+=("$1")
        shift
    done
    docker exec \
        -e GOURCE_SECONDS_PER_DAY="0.1" \
        -e GOURCE_TIME_SCALE="2.0" \
        -e FPS="25" \
        -e VIDEO_RESOLUTION="480p" \
        "${DOCKER_ARGS[@]}" \
        envisaged-redux \
        bash /visualization/runtime/entrypoint.sh
    local RESULT=$(sha512sum /workvol/video/output.mp4 | awk '{ print $1 }')
    if [ "${SAVE}" = "1" ]; then
        cp /workvol/video/output.mp4 /hostdir/v_${ID}.mp4
        echo "${RESULT}" >> /hostdir/metadata
    else
        # Check 512 sum matches
        local EXPECTED=$(awk "NR==${ID}" ${DIR}/metadata)
        if [ "${RESULT}" != "${EXPECTED}" ]; then
            exit 1
        fi
    fi

    docker restart envisaged-redux
}