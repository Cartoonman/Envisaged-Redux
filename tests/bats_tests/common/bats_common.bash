#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH
readonly ER_ROOT_DIRECTORY=/visualization
source "${CUR_DIR_PATH}/helpers/output.bash"
source "${CUR_DIR_PATH}/helpers/error.bash"
source "${CUR_DIR_PATH}/helpers/lang.bash"
source "${CUR_DIR_PATH}/helpers/assert.bash"


gource_args_test=("bash" "-c"  "source ${ER_ROOT_DIRECTORY}/runtime/common/common_templates.bash; gen_gource_args; echo \"\${gource_arg_array[@]}\";")

gource_test_entrypoint_1() {
    local -r type="$1"
    shift
    if [ "${type}" = "bool" ]; then
        gource_test_bools $@
    elif [ "${type}" = "var" ]; then
        gource_test_vars $@
    else 
        fail "Missing Type descriptor."
    fi
}

gource_test_entrypoint_2() {
    local -r type="$1"
    shift
    if [ "${type}" = "bool" ]; then
        gource_test_cond_bools $@
    elif [ "${type}" = "var" ]; then
        gource_test_cond_vars $@
    else 
        fail "Missing Type descriptor."
    fi
}

gource_test_vars() {
    local -r var_name="$1"
    local -r expected_result="$2"
    local -r rand_str="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9 ' | fold -w 32 | head -n 1)"
    local -r test1=("${expected_result} value")
    local -r test2=("${expected_result} Multi Word Value")
    local -r test3=("${expected_result} ${rand_str}")
    output="$(export ${var_name}="value"; "${gource_args_test[@]}")"
    assert_equal "${output}" "${test1[@]}"
    output="$(export ${var_name}="Multi Word Value"; "${gource_args_test[@]}")"
    assert_equal "${output}" "${test2[@]}"
    output="$(export ${var_name}=""; "${gource_args_test[@]}")"
    assert_equal "${output}"  "" 
    output="$(export ${var_name}="${rand_str}"; "${gource_args_test[@]}")"
    assert_equal "${output}" "${test3[@]}"
}

gource_test_bools() {
    local -r var_name="$1"
    local -r expected_result="$2"

    output="$(export ${var_name}="1"; "${gource_args_test[@]}")"
    assert_equal "${output}" "${expected_result}"
    output="$(export ${var_name}="0"; "${gource_args_test[@]}")"
    assert_equal "${output}" ""
    output="$(export ${var_name}=""; "${gource_args_test[@]}")"
    assert_equal "${output}"  "" 
}

gource_test_cond_vars() {
    local -r var_name="$1"
    local -r expected_result="$2"
    local -r ctrl_var="$3"
    local -r ctrl_var_key="$4"
    local -r ctrl_var_val="$5"
    local -r test1=("${ctrl_var_key}" "${ctrl_var_val}" "${expected_result}" "value")
    local -r test2=("${ctrl_var_key}" "${ctrl_var_val}" "${expected_result}" "Multi Word Value")
    local -r test3=("${ctrl_var_key}" "${ctrl_var_val}")
    output="$(export ${ctrl_var}="0"; export ${var_name}="value"; "${gource_args_test[@]}")"
    assert_equal "${output}" ""
    output="$(export ${ctrl_var}="0"; export ${var_name}="Multi Word Value"; "${gource_args_test[@]}")"
    assert_equal "${output}" ""
    output="$(export ${ctrl_var}="0"; export ${var_name}=""; "${gource_args_test[@]}")"
    assert_equal "${output}" ""
    output="$(export ${ctrl_var}=""; export ${var_name}="value"; "${gource_args_test[@]}")"
    assert_equal "${output}" ""
    output="$(export ${ctrl_var}=""; export ${var_name}="Multi Word Value"; "${gource_args_test[@]}")"
    assert_equal "${output}" ""
    output="$(export ${ctrl_var}=""; export ${var_name}=""; "${gource_args_test[@]}")"
    assert_equal "${output}" ""
    output="$(export ${ctrl_var}="1"; export ${var_name}="value"; "${gource_args_test[@]}")"
    assert_equal "${output}" "$(echo ${test1[@]})"
    output="$(export ${ctrl_var}="1"; export ${var_name}="Multi Word Value"; "${gource_args_test[@]}")"
    assert_equal "${output}" "$(echo ${test2[@]})"
    output="$(export ${ctrl_var}="1"; export ${var_name}=""; "${gource_args_test[@]}")"
    assert_equal "${output}" "$(echo ${test3[@]})"
}

gource_test_cond_bools() {
    local -r var_name="$1"
    local -r expected_result="$2"
    local -r ctrl_var="$3"
    local -r ctrl_var_key="$4"
    local -r ctrl_var_val="$5"
    local -r test1=("${ctrl_var_key}" "${ctrl_var_val}" "${expected_result}")
    local -r test2=("${ctrl_var_key}" "${ctrl_var_val}")
    local -r test3=("${ctrl_var_key}" "${ctrl_var_val}")
    output="$(export ${ctrl_var}="0"; export ${var_name}="1"; "${gource_args_test[@]}")"
    assert_equal "${output}" ""
    output="$(export ${ctrl_var}="0"; export ${var_name}="0"; "${gource_args_test[@]}")"
    assert_equal "${output}" ""
    output="$(export ${ctrl_var}="0"; export ${var_name}=""; "${gource_args_test[@]}")"
    assert_equal "${output}" ""
    output="$(export ${ctrl_var}=""; export ${var_name}="1"; "${gource_args_test[@]}")"
    assert_equal "${output}" ""
    output="$(export ${ctrl_var}=""; export ${var_name}="0"; "${gource_args_test[@]}")"
    assert_equal "${output}" ""
    output="$(export ${ctrl_var}=""; export ${var_name}=""; "${gource_args_test[@]}")"
    assert_equal "${output}" ""
    output="$(export ${ctrl_var}="1"; export ${var_name}="1"; "${gource_args_test[@]}")"
    assert_equal "${output}" "$(echo ${test1[@]})"
    output="$(export ${ctrl_var}="1"; export ${var_name}="0"; "${gource_args_test[@]}")"
    assert_equal "${output}" "$(echo ${test2[@]})"
    output="$(export ${ctrl_var}="1"; export ${var_name}=""; "${gource_args_test[@]}")"
    assert_equal "${output}" "$(echo ${test3[@]})"
}

gource_test_avatars() {
    local -r ctrl_var="$1"
    local -r ctrl_var_key="$2"
    local -r ctrl_var_val="$3"
    local -r test1=("${ctrl_var_key}" "${ctrl_var_val}")
    output="$(export ${ctrl_var}="0"; "${gource_args_test[@]}")"
    assert_equal "${output}" ""
    output="$(export ${ctrl_var}=""; "${gource_args_test[@]}")"
    assert_equal "${output}" ""
    output="$(export ${ctrl_var}="1"; "${gource_args_test[@]}")"
    assert_equal "${output}" "$(echo ${test1[@]})"
}

integration_run()
{
    local env_args=()
    while (( $# != 0 )); do
        env_args+=("$1")
        shift
    done
    printf "Test ${COUNT}\r" >&3
    local log_output="$( eval "${env_args[@]}" "${ER_ROOT_DIRECTORY}"/runtime/entrypoint.sh TEST NO_RUN 2>&1 )" runtime_exit_code=$?
    (( runtime_exit_code != 0 )) && echo -e "${log_output}" && fail "Failure detected on test #${COUNT}"
    if (( SAVE == 1 )); then
        printf "\n" >> "${ER_ROOT_DIRECTORY}"/cmd_test_data.txt
    else
        local actual_result="$(cat "${ER_ROOT_DIRECTORY}"/cmd_test_data.txt)"
        local expected_result="$(awk "NR==${COUNT}" "${ER_ROOT_DIRECTORY}"/tests/test_data/cmd_test_data.txt)"
        assert_equal "${actual_result}" "${expected_result}" || wdiff -n -w $'\033[30;41m' -x $'\033[0m' -y $'\033[30;42m' -z $'\033[0m' <(echo "${expected_result}") <(echo "${actual_result}") || fail "Failure detected on test #${COUNT}"
        rm "${ER_ROOT_DIRECTORY}"/cmd_test_data.txt
    fi
    (( ++COUNT ))
}
readonly -f integration_run

repo_run()
{
    local env_args=()
    while (( $# != 0 )); do
        env_args+=("$1")
        shift
    done
    printf "Test ${COUNT}\r" >&3
    local log_output="$( eval "${env_args[@]}" "${ER_ROOT_DIRECTORY}"/runtime/entrypoint.sh TEST NO_RUN 2>&1 )" runtime_exit_code=$?
    (( runtime_exit_code != 0 )) && echo -e "${log_output}" && fail "Failure detected on test #${COUNT}"
    if (( SAVE == 1 )); then
        mkdir -p /hostdir/repo
        cp "${ER_ROOT_DIRECTORY}"/development.log /hostdir/repo/r_"${COUNT}".log
    else
        local actual_result="$(cat "${ER_ROOT_DIRECTORY}"/development.log)"
        local expected_result="$(cat "${ER_ROOT_DIRECTORY}"/tests/test_data/repo/r_${COUNT}.log)"
        assert_equal "${actual_result}" "${expected_result}" || wdiff -n -w $'\033[30;41m' -x $'\033[0m' -y $'\033[30;42m' -z $'\033[0m' <(echo "${expected_result}") <(echo "${actual_result}") || fail "Failure detected on test #${COUNT}"
        rm "${ER_ROOT_DIRECTORY}"/development.log
    fi
    (( ++COUNT ))
}
readonly -f repo_run

entrypoint_failure_run()
{
    local env_args=()
    while (( $# != 0 )); do
        env_args+=("$1")
        shift
    done
    printf "Test ${COUNT}\r" >&3
    local log_output="$( eval "${env_args[@]}" "${ER_ROOT_DIRECTORY}"/runtime/entrypoint.sh 2>&1 )" runtime_exit_code=$?
    (( runtime_exit_code == 0 )) && echo -e "${log_output}" && fail "Expected failure but command succeeded on test #${COUNT}"
    (( ++COUNT ))
}
readonly -f entrypoint_failure_run

system_run()
{
    local env_args=()
    while (( $# != 0 )); do
        env_args+=("$1")
        shift
    done
    printf "Test ${COUNT}\r" >&3
    local log_output="$( eval "${env_args[@]}" "${ER_ROOT_DIRECTORY}"/runtime/entrypoint.sh 2>&1 )" runtime_exit_code=$?
    (( runtime_exit_code != 0 )) && echo -e "${log_output}" && fail "Failure on test #${COUNT}"
    local actual_result="$(sha512sum /visualization/video/output.mp4 | awk '{ print $1 }')"
    if (( SAVE == 1 )); then
        cp /visualization/video/output.mp4 /hostdir/v_"${COUNT}".mp4
        printf "${actual_result}\n" >> /hostdir/video_hashes.txt
    else
        # Check 512 sum matches
        local expected_result="$(awk "NR==${COUNT}" "${ER_ROOT_DIRECTORY}"/tests/test_data/video_hashes.txt)"
        assert_equal "${actual_result}" "${expected_result}" || fail "Failure detected on test #${COUNT}"
    fi
    rm -f "${ER_ROOT_DIRECTORY}"/video/output.mp4
    rm -f "${ER_ROOT_DIRECTORY}"/development.log
    (( ++COUNT ))
}
readonly -f system_run
