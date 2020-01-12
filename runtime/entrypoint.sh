#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: Apache-2.0 AND MIT

declare -r CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${CUR_DIR_PATH}/common/common_entrypoint.bash"

# Print Banner
print_intro

# Set exit code
exit_code=0

# Parse input args if any
parse_args "$@"

# Check runtime mode.
echo 0 > /visualization/html/live_preview
if [ "${ENABLE_LIVE_PREVIEW}" = "1" ]; then
    export LIVE_PREVIEW=1
    echo 1 > /visualization/html/live_preview
fi

# Check for video saving mode
if [ -d /visualization/video ]; then
    export USE_LOCAL_OUTPUT=1
else
    mkdir -p /visualization/video
fi

# Start Xvfb
log_notice "Starting Xvfb..."
Xvfb :99 -ac -screen 0 "${XVFB_WHD}" -nocursor -noreset -nolisten tcp &
xvfb_pid="$!"
ret_code=1
watch_start=${SECONDS}
while [ ${ret_code} -ne 0 ] && [ $((SECONDS-watch_start)) -le ${XVFB_TIMEOUT} ]; do
    xdpyinfo -display :99 > /dev/null 2>&1
    ret_code=$?
done
if [ $((SECONDS-watch_start)) -gt ${XVFB_TIMEOUT} ]; then
    log_error "Timeout: Xvfb failed to start properly. Exiting."
    exit 1
fi
log_success "Xvfb started successfully."

# Check which gource release is chosen
if [ "${USE_GOURCE_NIGHTLY}" = "1" ]; then
    export GOURCE_EXEC='gource_nightly'
    log_warn "Using $(${GOURCE_EXEC} -h | head -n 1) Nightly Release"
    export USE_NIGHTLY=1
else
    export GOURCE_EXEC='gource'
    log_notice "Using $(${GOURCE_EXEC} -h | head -n 1) Stable Release "
fi

# Check if repo exists
if [ ! -d /visualization/git_repo ]
then
    log_error "Error: git repo not found: /visualization/git_repo does not exist."
    exit 1
fi

# Check if this is a single or multi repo
if [ ! -d /visualization/git_repo/.git ]; then
    # Assume this is a multi-repo setup
    log_info "Detected potential multi-repo input. Assuming this is a multi-repo directory."
    t_count=0
    s_count=0
    logs=""
    for dir in $(find /visualization/git_repo/ -maxdepth 1 -mindepth 1 -type d -printf '%f\n')
    do
        log_notice "Checking ${dir}... "
        if [ ! -d /visualization/git_repo/"${dir}"/.git ]; then
            log_warn "/visualization/git_repo/${dir} is not a git repo, skipping..."
            continue
        fi
        if [ "${RECURSE_SUBMODULES}" = "1" ]; then
            log_info "Recursing through submodules in ${dir}"
            submod_paths=()
            cd /visualization/git_repo/"${dir}" && git submodule foreach --recursive '( echo "submod_paths+=($displaypath)" >> /visualization/submods.bash )'
            cd /visualization
            if [ ! -f /visualization/submods.bash ]; then
                log_warn "No submodules found in ${dir}. Continuing..."
            else
                . submods.bash
                rm  submods.bash
            fi
            submod_paths+=('') # include parent of course
            for submod_path in "${submod_paths[@]}"; do
                ((++t_count))
                set -e
                ${GOURCE_EXEC} --output-custom-log development${t_count}.log /visualization/git_repo/"${dir}"/"${submod_path}"
                set +e
                if [ "${submod_path}" != "" ]; then
                    sed -i -r "s#(.+)\|#\1|/${dir}/${submod_path}#" development${t_count}.log
                    ((s_count++))
                else
                    sed -i -r "s#(.+)\|#\1|/${dir}#" development${t_count}.log
                fi

                logs="${logs} development${t_count}.log"
            done
        else
            ((++t_count))
            set -e
            ${GOURCE_EXEC} --output-custom-log development${t_count}.log /visualization/git_repo/"${dir}"
            set +e
            sed -i -r "s#(.+)\|#\1|/${dir}#" development${t_count}.log
            logs="${logs} development${t_count}.log"
        fi
    done
    log_success "Processed $((t_count-s_count)) repos and ${s_count} submodules."
    cat ${logs} | sort -n > development.log
    rm "${logs}"
else
    # Assume this is a single-repo setup
    log_info "Detected single-repo input."
    s_count=0
    if [ "${RECURSE_SUBMODULES}" = "1" ]; then
        log_info "Recursing through submodules."
        submod_paths=()
        cd /visualization/git_repo && git submodule foreach --recursive '( echo "submod_paths+=($displaypath)" >> /visualization/submods.bash )'
        cd /visualization
        if [ ! -f /visualization/submods.bash ]; then
            log_warn "No submodules found. Continuing..."
        else
            . submods.bash
            rm  submods.bash
        fi
        logs=""
        submod_paths+=('') # include parent of course
        for submod_path in "${submod_paths[@]}"; do
            ((++s_count))
            set -e
            ${GOURCE_EXEC} --output-custom-log development${s_count}.log /visualization/git_repo/"${submod_path}"
            set +e
            if [ "${submod_path}" != "" ]; then
                sed -i -r "s#(.+)\|#\1|/${submod_path}#" development${s_count}.log
            fi
            logs="${logs} development${s_count}.log"
        done
        ((--s_count)) # Account for repo itself
        cat ${logs} | sort -n > development.log
        rm "${logs}"
    else
        # Single repo no submods - simple case.
        set -e
        ${GOURCE_EXEC} --output-custom-log development.log /visualization/git_repo
        set +e
    fi
    log_success "Processed 1 repo and ${s_count} submodules."
fi
log_info "Git logs Parsed."

# Check for avatar directory mount.
if [ -d /visualization/avatars ]; then
    log_info "Using avatars directory"
    export USE_AVATARS=1
fi

# Check for captions
if [ -f /visualization/captions.txt ]; then
    log_info "Using captions file"
    export USE_CAPTIONS=1
fi

# Check for logo
if [ -f /visualization/logo.image ]; then
    log_notice "Possible logo file detected. Attempting to transform..."
    set -e
    convert -geometry x160 /visualization/logo.image /visualization/logo_txfrmed.image
    set +e
    log_success "Success. Using logo file"
    export LOGO=" -i /visualization/logo_txfrmed.image "
fi

# Start the httpd to serve the video.
log_notice "Starting httpd..."
cp /visualization/html/processing_gource.html /visualization/html/index.html
lighttpd -f /visualization/runtime/http.conf -D &
httpd_pid="$!"
log_success "httpd started successfully."
trap 'echo "Stopping proccesses PIDs: ($xvfb_pid, $httpd_pid)";\
    [ -n "$xvfb_pid" -a -e /proc/$xvfb_pid ] && kill $xvfb_pid;\
    [ -n "$httpd_pid" -a -e /proc/$httpd_pid ] && kill $httpd_pid' SIGINT SIGTERM

# Run the visualization
if [ -n "${TEMPLATE}" ]; then
    case ${TEMPLATE} in
        border)
            log_info "Using ${TEMPLATE} template..."
            /visualization/runtime/templates/border.sh
            exit_code=$?
            ;;
        standard)
            log_info "Using ${TEMPLATE} template..."
            /visualization/runtime/templates/standard.sh
            exit_code=$?
            ;;
        *)
            log_error "Unknown template option ${TEMPLATE}"
            exit 1
            ;;
    esac
else
    log_info "No template choice provided, Defaulting to standard template..."
    /visualization/runtime/templates/standard.sh
    exit_code=$?
fi

if [ "${TEST}" != "1" ]; then
    if [ -f /visualization/video/output.mp4 ]; then
        chmod 666 /visualization/video/output.mp4
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
[ -n "$xvfb_pid" -a -e /proc/$xvfb_pid ] && kill $xvfb_pid
[ -n "$httpd_pid" -a -e /proc/$httpd_pid ] && kill $httpd_pid
echo "Exiting with code ${exit_code}"
exit "${exit_code}"
