#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: Apache-2.0 AND MIT
set -e

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH
source "${CUR_DIR_PATH}/common/common.bash"
source "${CUR_DIR_PATH}/common/api_dict.bash"


print_intro()
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
    version="$( cat "${CUR_DIR_PATH}/../VERSION" )"
    printf "%b%s%b\n\n" "\033[1m\033[4m" "Version ${version}" "\033[0m"
}
readonly -f print_intro

validate_env_vars()
{
    local env_vars
    readarray -d $'\n' -t env_vars <<< "$( printenv | sed 's@=.*@@' | grep -e '^GOURCE*' -e '^RUNTIME*' -e '^RENDER*' -e '^PREVIEW*' | sort -d )"
    for var in ${env_vars[@]}; do
        if (( _api_dict[${var}] != 1 )); then
            log_warn "${var} is not a valid or known variable."
            unset "${var}"
        fi
    done
   if (( RUNTIME_PRINT_VARS == 1 )); then
        log_notice "Printing Configuration Variables:"
        local print_vars
        readarray -d $'\n' -t print_vars <<< "$( printenv | grep -e '^GOURCE*' -e '^RUNTIME*' -e '^RENDER*' -e '^PREVIEW*' | sort -d )"
        for var in "${print_vars[@]}"; do
            printf "        %s\n" "${var}"
        done
    fi
}
readonly -f validate_env_vars

parse_args()
{
    while [[ $# -gt 0 ]]; do
        local k
        k="$1"
        case $k in
            DEBUG)
                declare -grix RT_DEBUG=1
                log_warn "DEBUG Flag Invoked"
                ;;
            HOLD)
                log_info "Test mode enabled. Spinning main thread. Run docker stop on container when complete."
                trap 'exit 143' SIGTERM # exit = 128 + 15 (SIGTERM)
                tail -f /dev/null & wait ${!}
                exit 0
                ;;
            TEST)
                declare -grix RT_TEST=1
                log_warn "TEST Flag Invoked"
                ;;
            NO_RUN)
                declare -grix RT_NO_RUN=1
                log_warn "NO_RUN Flag Invoked"
                ;;
        esac
        shift
    done
}
readonly -f parse_args

parse_configs()
{
    # Check runtime mode.
    echo 0 > "${ER_ROOT_DIRECTORY}"/html/live_preview
    if [[ "${RUNTIME_LIVE_PREVIEW}" == "1" ]]; then
        declare -grix RT_LIVE_PREVIEW=1
        echo 1 > "${ER_ROOT_DIRECTORY}"/html/live_preview
    fi

    # Check for video saving mode
    if [ -d "${ER_ROOT_DIRECTORY}"/video ]; then
        declare -grix RT_LOCAL_OUTPUT=1
    else
        mkdir -p "${ER_ROOT_DIRECTORY}"/video
    fi

    # Check which gource release is chosen
    if [[ "${RUNTIME_GOURCE_NIGHTLY}" == "1" ]]; then
        declare -grx RT_GOURCE_EXEC='gource_nightly'
        log_notice "Using $("${RT_GOURCE_EXEC}" -h | head -n 1) Nightly Release"
        declare -grix RT_NIGHTLY=1
    else
        declare -grx RT_GOURCE_EXEC='gource'
        log_info "Using $("${RT_GOURCE_EXEC}" -h | head -n 1) Stable Release "
    fi

    # Check for avatar directory mount.
    if [ -d "${ER_ROOT_DIRECTORY}"/avatars ]; then
        log_info "Using avatars directory"
        declare -grix RT_AVATARS=1
    fi

    # Check for captions
    if [ -f "${ER_ROOT_DIRECTORY}"/captions.txt ]; then
        log_info "Using captions file"
        declare -grix RT_CAPTIONS=1
    fi

    # Check for logo
    if [ -f "${ER_ROOT_DIRECTORY}"/logo.image ]; then
        log_notice "Possible logo file detected. Attempting to transform..."
        set +e
        convert -geometry x160 "${ER_ROOT_DIRECTORY}"/logo.image "${ER_ROOT_DIRECTORY}"/logo_txfrmed.image
        if (( $? != 0 )); then
            log_error "Error: ImageMagick failed to convert the supplied logo file. Please check image file passed or convert to another format."
            exit 1
        else
            log_success "Success. Using logo file"
            declare -grx RT_LOGO=" -i "${ER_ROOT_DIRECTORY}"/logo_txfrmed.image "
        fi
    fi


    # Check if repo exists
    if [ ! -d "${ER_ROOT_DIRECTORY}"/git_repo ]
    then
        log_error "Error: git repo not found: "${ER_ROOT_DIRECTORY}"/git_repo does not exist."
        exit 1
    fi
    return 0
}
readonly -f parse_configs

process_single_repo()
{
    declare -i submod_count=0
    if [[ "${RUNTIME_RECURSE_SUBMODULES}" == "1" ]]; then
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
            "${RT_GOURCE_EXEC}" --output-custom-log development"${submod_count}".log "${ER_ROOT_DIRECTORY}"/git_repo/"${submod_path}"
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
        "${RT_GOURCE_EXEC}" --output-custom-log development.log "${ER_ROOT_DIRECTORY}"/git_repo
    fi
    log_success "Processed 1 repo and ${submod_count} submodules."
    return 0
}
readonly -f process_single_repo

process_multi_repo()
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
        if [[ "${RUNTIME_RECURSE_SUBMODULES}" == "1" ]]; then
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
                "${RT_GOURCE_EXEC}" --output-custom-log development"${total_count}".log "${ER_ROOT_DIRECTORY}"/git_repo/"${dir}"/"${submod_path}"
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
            "${RT_GOURCE_EXEC}" --output-custom-log development"${total_count}".log "${ER_ROOT_DIRECTORY}"/git_repo/"${dir}"
            sed -i -r "s#(.+)\|#\1|/${dir}#" development${total_count}.log
            logs+=("development${total_count}.log")
        fi
    done <<< "$(find "${ER_ROOT_DIRECTORY}"/git_repo/ -maxdepth 1 -mindepth 1 -type d -printf '%f\n')"
    log_success "Processed $((total_count-submod_count)) repos and ${submod_count} submodules."
    sort -n "${logs[@]}" > development.log
    rm "${logs[@]}"
    return 0
}
readonly -f process_multi_repo

process_repos()
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
    return 0
}
readonly -f process_repos

start_httpd()
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
        stop_process ${_HTTPD_PID}
        exit 1
    fi
    log_success "httpd started successfully."
    return 0
}
readonly -f start_httpd

start_xvfb()
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
        stop_process ${_HTTPD_PID}
        stop_process ${_XVFB_PID}
        exit 1
    fi
    log_success "Xvfb started successfully."
    return 0
}
readonly -f start_xvfb

start_services()
{
    # Disable strict error handling during this method.
    set +e

    start_httpd

    start_xvfb

    # Re-enable strict error handling
    set -e

    # Trap the services so we can shut them down properly later.
    trap 'stop_process ${_XVFB_PID};\
        stop_process ${_HTTPD_PID};\
        log_debug "Exiting with code ${EXIT_CODE} ";\
        exit ${EXIT_CODE};' SIGINT SIGTERM
    return 0
}
readonly -f start_services


start_render()
{
    # Disable strict error handling during this method.
    set +e
    # Start the visualization render based on template chosen
    if [ -n "${RUNTIME_TEMPLATE}" ]; then
        case ${RUNTIME_TEMPLATE} in
            border)
                log_info "Using ${RUNTIME_TEMPLATE} template..."
                "${ER_ROOT_DIRECTORY}"/runtime/templates/border.sh
                EXIT_CODE=$?
                ;;
            standard)
                log_info "Using ${RUNTIME_TEMPLATE} template..."
                "${ER_ROOT_DIRECTORY}"/runtime/templates/standard.sh
                EXIT_CODE=$?
                ;;
            *)
                log_error "Unknown template option ${RUNTIME_TEMPLATE}"
                EXIT_CODE=1
                kill -TERM $$
                ;;
        esac
    else
        log_info "No template choice provided, Defaulting to standard template..."
        "${ER_ROOT_DIRECTORY}"/runtime/templates/standard.sh
        EXIT_CODE=$?
    fi

    (( EXIT_CODE != 0 )) && kill -TERM $$

    # Re-enable strict error handling
    set -e
    return 0
}
readonly -f start_render


handle_output()
{
    # Handle output
    if [ -f "${ER_ROOT_DIRECTORY}"/video/output.mp4 ]; then
        chmod 666 "${ER_ROOT_DIRECTORY}"/video/output.mp4
        log_success "Visualization process is complete."
    else
        log_error "Visualization process failed."
        EXIT_CODE=1
        kill -TERM $$
    fi

    if (( RT_LOCAL_OUTPUT != 1 )); then
        # Wait for httpd process to end.
        while kill -0 ${_HTTPD_PID} >/dev/null 2>&1; do
            wait
        done
    fi
    return 0
}
readonly -f handle_output

main()
{
    # Print Banner
    print_intro

    # Local Constants
    declare -gri _XVFB_TIMEOUT=60
    declare -gri _HTTPD_TIMEOUT=15

    # Set exit code
    declare -gix EXIT_CODE=0

    # Validate env vars
    validate_env_vars

    # Parse input args if any
    parse_args "$@"

    # Handle runtime configuration and checks
    parse_configs

    # Traverse repos and generate git logs to process
    process_repos

    # Activate services
    (( RT_NO_RUN != 1 )) && start_services

    # Start visualization rendering process
    start_render

    # Handle the output
    (( RT_NO_RUN != 1 )) && handle_output



    # Exit
    stop_process ${_XVFB_PID}
    stop_process ${_HTTPD_PID}
    log_debug "Exiting at end with code ${EXIT_CODE}"
    exit "${EXIT_CODE}"
}
readonly -f main


# Run main
main "$@"
