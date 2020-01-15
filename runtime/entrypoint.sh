#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: Apache-2.0 AND MIT

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${CUR_DIR_PATH}/common/common_entrypoint.bash"

set -e

# Print Banner
print_intro

# Set exit code
exit_code=0

# Parse input args if any
parse_args "$@"

# Handle runtime configuration and checks
parse_configs

# Check if this is a single or multi repo
if [ ! -d "${ER_ROOT_DIRECTORY}"/git_repo/.git ]; then
    # Assume this is a multi-repo setup
    log_info "Detected potential multi-repo input. Assuming this is a multi-repo directory."
    t_count=0
    s_count=0
    logs=()
    while read -r dir; do
        log_notice "Checking ${dir}... "
        if [ ! -d "${ER_ROOT_DIRECTORY}"/git_repo/"${dir}"/.git ]; then
            log_warn "${ER_ROOT_DIRECTORY}/git_repo/${dir} is not a git repo, skipping..."
            continue
        fi
        if [ "${RECURSE_SUBMODULES}" = "1" ]; then
            log_info "Recursing through submodules in ${dir}"
            submod_paths=()
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
                ((++t_count))
                ${GOURCE_EXEC} --output-custom-log development"${t_count}".log "${ER_ROOT_DIRECTORY}"/git_repo/"${dir}"/"${submod_path}"
                if [ "${submod_path}" != "" ]; then
                    sed -i -r "s#(.+)\|#\1|/${dir}/${submod_path}#" development${t_count}.log
                    ((++s_count))
                else
                    sed -i -r "s#(.+)\|#\1|/${dir}#" development${t_count}.log
                fi
                logs+=("development${t_count}.log")
            done
        else
            ((++t_count))
            ${GOURCE_EXEC} --output-custom-log development"${t_count}".log "${ER_ROOT_DIRECTORY}"/git_repo/"${dir}"
            sed -i -r "s#(.+)\|#\1|/${dir}#" development${t_count}.log
            logs+=("development${t_count}.log")
        fi
    done <<< "$(find "${ER_ROOT_DIRECTORY}"/git_repo/ -maxdepth 1 -mindepth 1 -type d -printf '%f\n')"
    log_success "Processed $((t_count-s_count)) repos and ${s_count} submodules."
    sort -n "${logs[@]}" > development.log
    rm "${logs[@]}"
else
    # Assume this is a single-repo setup
    log_info "Detected single-repo input."
    s_count=0
    if [ "${RECURSE_SUBMODULES}" = "1" ]; then
        log_info "Recursing through submodules."
        submod_paths=()
        cd "${ER_ROOT_DIRECTORY}"/git_repo && git submodule foreach --recursive '( echo "submod_paths+=($displaypath)" >> '"${ER_ROOT_DIRECTORY}"'/submods.bash )'
        cd "${ER_ROOT_DIRECTORY}"
        if [ ! -f "${ER_ROOT_DIRECTORY}"/submods.bash ]; then
            log_warn "No submodules found. Continuing..."
        else
            source submods.bash
            rm  submods.bash
        fi
        logs=()
        submod_paths+=('') # include parent of course
        for submod_path in "${submod_paths[@]}"; do
            ((++s_count))
            ${GOURCE_EXEC} --output-custom-log development"${s_count}".log "${ER_ROOT_DIRECTORY}"/git_repo/"${submod_path}"
            if [ "${submod_path}" != "" ]; then
                sed -i -r "s#(.+)\|#\1|/${submod_path}#" development"${s_count}".log
            fi
            logs+=("development${s_count}.log")
        done
        ((s_count--)) # Account for repo itself
        sort -n "${logs[@]}" > development.log
        rm "${logs[@]}"
    else
        # Single repo no submods - simple case.
        ${GOURCE_EXEC} --output-custom-log development.log "${ER_ROOT_DIRECTORY}"/git_repo
    fi
    log_success "Processed 1 repo and ${s_count} submodules."
fi
log_info "Git logs Parsed."


# Begin Services
# Disable
set +e
# Start the httpd to serve the video.
log_notice "Starting httpd..."
cp "${ER_ROOT_DIRECTORY}"/html/processing_gource.html "${ER_ROOT_DIRECTORY}"/html/index.html
lighttpd -f "${ER_ROOT_DIRECTORY}"/runtime/http.conf -D &
httpd_pid="$!"
curl_exit_code=1
watch_start=${SECONDS}
while [ ${curl_exit_code} -ne 0 ] && [ $((SECONDS-watch_start)) -le ${HTTPD_TIMEOUT} ]; do
    curl -f --max-time 5 -s localhost:80 > /dev/null
    curl_exit_code=$?
done
if [ $((SECONDS-watch_start)) -gt ${HTTPD_TIMEOUT} ]; then
    log_error "Timeout: httpd failed to start after ${HTTPD_TIMEOUT} seconds. Observed error code ${curl_exit_code}."
    [ -n "$httpd_pid" ] && [ -e /proc/$httpd_pid ] && kill $httpd_pid
    exit 1
fi
log_success "httpd started successfully."


# Start Xvfb
log_notice "Starting Xvfb..."
Xvfb :99 -ac -screen 0 "${XVFB_WHD}" -nocursor -noreset -nolisten tcp &
xvfb_pid="$!"
xdpy_exit_code=1
watch_start=${SECONDS}
while [ ${xdpy_exit_code} -ne 0 ] && [ $((SECONDS-watch_start)) -le ${XVFB_TIMEOUT} ]; do
    xdpyinfo -display :99 > /dev/null 2>&1
    xdpy_exit_code=$?
done
if [ $((SECONDS-watch_start)) -gt ${XVFB_TIMEOUT} ]; then
    log_error "Timeout: Xvfb failed to start after ${XVFB_TIMEOUT} seconds. Observed error code ${xdpy_exit_code}."
    [ -n "$httpd_pid" ] && [ -e /proc/$httpd_pid ] && kill $httpd_pid
    [ -n "$xvfb_pid" ] && [ -e /proc/$xvfb_pid ] && kill $xvfb_pid
    exit 1
fi
log_success "Xvfb started successfully."


# Trap the services so we can shut them down properly later.
trap 'echo "Stopping proccesses PIDs: ($xvfb_pid, $httpd_pid)";\
    [ -n "$xvfb_pid" ] && [ -e /proc/$xvfb_pid ] && kill $xvfb_pid;\
    [ -n "$httpd_pid" ] && [ -e /proc/$httpd_pid ] && kill $httpd_pid' SIGINT SIGTERM

# Start the visualization render based on template chosen
if [ -n "${TEMPLATE}" ]; then
    case ${TEMPLATE} in
        border)
            log_info "Using ${TEMPLATE} template..."
            "${ER_ROOT_DIRECTORY}"/runtime/templates/border.sh
            exit_code=$?
            ;;
        standard)
            log_info "Using ${TEMPLATE} template..."
            "${ER_ROOT_DIRECTORY}"/runtime/templates/standard.sh
            exit_code=$?
            ;;
        *)
            log_error "Unknown template option ${TEMPLATE}"
            exit 1
            ;;
    esac
else
    log_info "No template choice provided, Defaulting to standard template..."
    "${ER_ROOT_DIRECTORY}"/runtime/templates/standard.sh
    exit_code=$?
fi

# Handle output (if this wasn't a test run)
if [ "${TEST}" != "1" ]; then
    if [ -f "${ER_ROOT_DIRECTORY}"/video/output.mp4 ]; then
        chmod 666 "${ER_ROOT_DIRECTORY}"/video/output.mp4
        log_success "Visualization process is complete."
    else
        log_error "Visualization process failed."
    fi

    if [ "${USE_LOCAL_OUTPUT}" != "1" ]; then
        # Wait for httpd process to end.
        while kill -0 $httpd_pid >/dev/null 2>&1; do
            wait
        done
    fi
fi


# Exit
[ -n "$xvfb_pid" ] && [ -e /proc/$xvfb_pid ] && kill $xvfb_pid
[ -n "$httpd_pid" ] && [ -e /proc/$httpd_pid ] && kill $httpd_pid
echo "Exiting with code ${exit_code}"
exit "${exit_code}"
