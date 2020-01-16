#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: Apache-2.0 AND MIT
set -e

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH
source "${CUR_DIR_PATH}/common/common.bash"


function print_intro
{
    cat << "EOF"
 _____            _                          _    ____          _
| ____|_ ____   _(_)___  __ _  __ _  ___  __| |  |  _ \ ___  __| |_   ___  __
|  _| | '_ \ \ / / / __|/ _` |/ _` |/ _ \/ _` |  | |_) / _ \/ _` | | | \ \/ /
| |___| | | \ V /| \__ \ (_| | (_| |  __/ (_| |  |  _ <  __/ (_| | |_| |>  <
|_____|_| |_|\_/ |_|___/\__,_|\__, |\___|\__,_|  |_| \_\___|\__,_|\__,_/_/\_\
******************************|___/******************************************
EOF
    local version
    version=$( cat "${CUR_DIR_PATH}/../VERSION" )
    printf "%s\n\n" "Version ${version}"
}
readonly -f print_intro

function parse_args
{
    while [[ $# -gt 0 ]]; do
        local k
        k="$1"
        case $k in
            HOLD)
                log_info "Test mode enabled. Spinning main thread. Run docker stop on container when complete."
                trap 'exit 143' SIGTERM # exit = 128 + 15 (SIGTERM)
                tail -f /dev/null & wait ${!}
                exit 0
                ;;
            TEST)
                declare -grix CFG_TEST=1
                log_warn "TEST Flag Invoked"
                ;;
            NO_RUN)
                declare -grix CFG_NO_RUN=1
                log_warn "NO_RUN Flag Invoked"
                ;;
        esac
        shift
    done
}
readonly -f parse_args

function parse_configs
{
    # Check runtime mode.
    echo 0 > /visualization/html/live_preview
    if [[ "${ENABLE_LIVE_PREVIEW}" == "1" ]]; then
        declare -grix CFG_LIVE_PREVIEW=1
        echo 1 > /visualization/html/live_preview
    fi

    # Check for video saving mode
    if [ -d /visualization/video ]; then
        declare -grix CFG_LOCAL_OUTPUT=1
    else
        mkdir -p /visualization/video
    fi

    # Check which gource release is chosen
    if [[ "${USE_GOURCE_NIGHTLY}" == "1" ]]; then
        declare -grx CFG_GOURCE_EXEC='gource_nightly'
        log_notice "Using $("${CFG_GOURCE_EXEC}" -h | head -n 1) Nightly Release"
        declare -grix CFG_NIGHTLY=1
    else
        declare -grx CFG_GOURCE_EXEC='gource'
        log_info "Using $("${CFG_GOURCE_EXEC}" -h | head -n 1) Stable Release "
    fi

    # Check for avatar directory mount.
    if [ -d /visualization/avatars ]; then
        log_info "Using avatars directory"
        declare -grix CFG_AVATARS=1
    fi

    # Check for captions
    if [ -f /visualization/captions.txt ]; then
        log_info "Using captions file"
        declare -grix CFG_CAPTIONS=1
    fi

    # Check for logo
    if [ -f /visualization/logo.image ]; then
        log_notice "Possible logo file detected. Attempting to transform..."
        convert -geometry x160 /visualization/logo.image /visualization/logo_txfrmed.image
        log_success "Success. Using logo file"
        declare -grx CFG_LOGO=" -i /visualization/logo_txfrmed.image "
    fi


    # Check if repo exists
    if [ ! -d /visualization/git_repo ]
    then
        log_error "Error: git repo not found: /visualization/git_repo does not exist."
        exit 1
    fi
}
readonly -f parse_configs

function process_single_repo
{
    declare -i submod_count=0
    if [[ "${RECURSE_SUBMODULES}" == "1" ]]; then
        log_info "Recursing through submodules."
        declare -a submod_paths=()
        cd "${ER_ROOT_DIRECTORY}"/git_repo && git submodule foreach --recursive '( echo "submod_paths+=($displaypath)" >> '"${ER_ROOT_DIRECTORY}"'/submods.bash )'
        cd "${ER_ROOT_DIRECTORY}"
        if [ ! -f "${ER_ROOT_DIRECTORY}"/submods.bash ]; then
            log_warn "No submodules found. Continuing..."
        else
            source submods.bash
            rm  submods.bash
        fi
        declare -a logs=()
        submod_paths+=('') # include parent of course
        for submod_path in "${submod_paths[@]}"; do
            ((++submod_count))
            "${CFG_GOURCE_EXEC}" --output-custom-log development"${submod_count}".log "${ER_ROOT_DIRECTORY}"/git_repo/"${submod_path}"
            if [ -n "${submod_path}" ]; then
                sed -i -r "s#(.+)\|#\1|/${submod_path}#" development"${submod_count}".log
            fi
            logs+=("development${submod_count}.log")
        done
        ((submod_count--)) # Account for repo itself
        sort -n "${logs[@]}" > development.log
        rm "${logs[@]}"
    else
        # Single repo no submods - simple case.
        "${CFG_GOURCE_EXEC}" --output-custom-log development.log "${ER_ROOT_DIRECTORY}"/git_repo
    fi
    log_success "Processed 1 repo and ${submod_count} submodules."
}
readonly -f process_single_repo

function process_multi_repo
{
    declare -i total_count=0
    declare -i submod_count=0
    declare -a logs=()
    while read -r dir; do
        log_notice "Checking ${dir}... "
        if [ ! -d "${ER_ROOT_DIRECTORY}"/git_repo/"${dir}"/.git ]; then
            log_warn "${ER_ROOT_DIRECTORY}/git_repo/${dir} is not a git repo, skipping..."
            continue
        fi
        if [[ "${RECURSE_SUBMODULES}" == "1" ]]; then
            log_info "Recursing through submodules in ${dir}"
            declare -a submod_paths=()
            cd "${ER_ROOT_DIRECTORY}"/git_repo/"${dir}" && git submodule foreach --recursive '( echo "submod_paths+=($displaypath)" >> '"${ER_ROOT_DIRECTORY}"'/submods.bash )'
            cd "${ER_ROOT_DIRECTORY}"
            if [ ! -f "${ER_ROOT_DIRECTORY}"/submods.bash ]; then
                log_warn "No submodules found in ${dir}. Continuing..."
            else
                source submods.bash
                rm submods.bash
            fi
            submod_paths+=('') # include parent of course
            for submod_path in "${submod_paths[@]}"; do
                ((++total_count))
                "${CFG_GOURCE_EXEC}" --output-custom-log development"${total_count}".log "${ER_ROOT_DIRECTORY}"/git_repo/"${dir}"/"${submod_path}"
                if [ -n "${submod_path}" ]; then
                    sed -i -r "s#(.+)\|#\1|/${dir}/${submod_path}#" development${total_count}.log
                    ((++submod_count))
                else
                    sed -i -r "s#(.+)\|#\1|/${dir}#" development${total_count}.log
                fi
                logs+=("development${total_count}.log")
            done
        else
            ((++total_count))
            "${CFG_GOURCE_EXEC}" --output-custom-log development"${total_count}".log "${ER_ROOT_DIRECTORY}"/git_repo/"${dir}"
            sed -i -r "s#(.+)\|#\1|/${dir}#" development${total_count}.log
            logs+=("development${total_count}.log")
        fi
    done <<< "$(find "${ER_ROOT_DIRECTORY}"/git_repo/ -maxdepth 1 -mindepth 1 -type d -printf '%f\n')"
    log_success "Processed $((total_count-submod_count)) repos and ${submod_count} submodules."
    sort -n "${logs[@]}" > development.log
    rm "${logs[@]}"
}
readonly -f process_multi_repo

function process_repos
{
    # Check if this is a single or multi repo
    if [ ! -d "${ER_ROOT_DIRECTORY}"/git_repo/.git ]; then
        log_info "Detected potential multi-repo input. Assuming this is a multi-repo directory."
        process_multi_repo
    else
        log_info "Detected single-repo input."
        process_single_repo
    fi
    log_info "Git logs Parsed."
}
readonly -f process_repos

function start_httpd
{
    log_notice "Starting httpd..."
    cp "${ER_ROOT_DIRECTORY}"/html/processing_gource.html "${ER_ROOT_DIRECTORY}"/html/index.html
    lighttpd -f "${ER_ROOT_DIRECTORY}"/runtime/http.conf -D &
    _HTTPD_PID=$!
    typeset -gir _HTTPD_PID
    declare -i curl_exit_code=1
    declare -i watch_start=${SECONDS}
    while (( curl_exit_code != 0 )) && (( SECONDS - watch_start <= _HTTPD_TIMEOUT )); do
        curl -f --max-time 5 -s localhost:80 > /dev/null
        curl_exit_code=$?
    done
    if (( SECONDS - watch_start > _HTTPD_TIMEOUT )); then
        log_error "Timeout: httpd failed to start after ${_HTTPD_TIMEOUT} seconds. Observed error code ${curl_exit_code}."
        [ -n "${_HTTPD_PID}" ] && [ -e /proc/${_HTTPD_PID} ] && kill ${_HTTPD_PID}
        exit 1
    fi
    log_success "httpd started successfully."
}
readonly start_httpd

function start_xvfb
{
    log_notice "Starting Xvfb..."
    Xvfb :99 -ac -screen 0 "${XVFB_WHD}" -nocursor -noreset -nolisten tcp &
    _XVFB_PID=$!
    typeset -gir _XVFB_PID
    declare -i xdpy_exit_code=1
    declare -i watch_start=${SECONDS}
    while (( xdpy_exit_code != 0 )) && (( SECONDS - watch_start <= _XVFB_TIMEOUT )); do
        xdpyinfo -display :99 > /dev/null 2>&1
        xdpy_exit_code=$?
    done
    if (( SECONDS - watch_start > _XVFB_TIMEOUT )); then
        log_error "Timeout: Xvfb failed to start after ${_XVFB_TIMEOUT} seconds. Observed error code ${xdpy_exit_code}."
        [ -n "${_HTTPD_PID}" ] && [ -e /proc/${_HTTPD_PID} ] && kill ${_HTTPD_PID}
        [ -n "${_XVFB_PID}" ] && [ -e /proc/${_XVFB_PID} ] && kill ${_XVFB_PID}
        exit 1
    fi
    log_success "Xvfb started successfully."
}
readonly start_xvfb

function start_services
{
    # Disable strict error handling during this method.
    set +e

    start_httpd

    start_xvfb

    # Enable strict error handling
    set -e

    # Trap the services so we can shut them down properly later.
    trap 'echo "Stopping proccesses PIDs: (${_XVFB_PID}, ${_HTTPD_PID})";\
        [ -n "${_XVFB_PID}" ] && [ -e /proc/${_XVFB_PID} ] && kill ${_XVFB_PID};\
        [ -n "${_HTTPD_PID}" ] && [ -e /proc/${_HTTPD_PID} ] && kill ${_HTTPD_PID}' SIGINT SIGTERM
}
readonly start_services


function start_render
{
    # Start the visualization render based on template chosen
    if [ -n "${TEMPLATE}" ]; then
        case ${TEMPLATE} in
            border)
                log_info "Using ${TEMPLATE} template..."
                "${ER_ROOT_DIRECTORY}"/runtime/templates/border.sh
                _EXIT_CODE=$?
                ;;
            standard)
                log_info "Using ${TEMPLATE} template..."
                "${ER_ROOT_DIRECTORY}"/runtime/templates/standard.sh
                _EXIT_CODE=$?
                ;;
            *)
                log_error "Unknown template option ${TEMPLATE}"
                exit 1
                ;;
        esac
    else
        log_info "No template choice provided, Defaulting to standard template..."
        "${ER_ROOT_DIRECTORY}"/runtime/templates/standard.sh
        _EXIT_CODE=$?
    fi
}
readonly start_render


function handle_output
{
    # Handle output (if this wasn't a test run)

    if (( CFG_TEST != 1 )); then
        if [ -f "${ER_ROOT_DIRECTORY}"/video/output.mp4 ]; then
            chmod 666 "${ER_ROOT_DIRECTORY}"/video/output.mp4
            log_success "Visualization process is complete."
        else
            log_error "Visualization process failed."
        fi

        if (( CFG_LOCAL_OUTPUT != 1 )); then
            # Wait for httpd process to end.
            while kill -0 ${_HTTPD_PID} >/dev/null 2>&1; do
                wait
            done
        fi
    fi
}
readonly handle_output

function main
{
    # Print Banner
    print_intro

    # Local Constants
    declare -gri _XVFB_TIMEOUT=60
    declare -gri _HTTPD_TIMEOUT=15

    # Set exit code
    declare -gi _EXIT_CODE=0

    # Parse input args if any
    parse_args "$@"

    # Handle runtime configuration and checks
    parse_configs

    # Traverse repos and generate git logs to process
    process_repos

    # Activate services
    start_services

    # Start visualization rendering process
    start_render

    # Handle the output
    handle_output



    # Exit
    [ -n "${_XVFB_PID}" ] && [ -e /proc/${_XVFB_PID} ] && kill ${_XVFB_PID}
    [ -n "${_HTTPD_PID}" ] && [ -e /proc/${_HTTPD_PID} ] && kill ${_HTTPD_PID}
    echo "Exiting with code ${_EXIT_CODE}"
    exit "${_EXIT_CODE}"

}
readonly main


# Run main
main "$@"
