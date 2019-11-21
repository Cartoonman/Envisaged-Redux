#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: MIT

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. "${DIR}/common/common.bash"

# Print Banner
print_intro


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
Xvfb :99 -ac -screen 0 $XVFB_WHD -nocursor -noreset -nolisten tcp &
xvfb_pid="${!}"
RET_CODE=1
WATCH_START=${SECONDS}
while [ ${RET_CODE} -ne 0 ] && [ $(( ${SECONDS} - ${WATCH_START} )) -le ${XVFB_TIMEOUT} ]; do
    xdpyinfo -display :99 &> /dev/null
    RET_CODE=${?}
done
if [ $(( ${SECONDS} - ${WATCH_START} )) -gt ${XVFB_TIMEOUT} ]; then
    log_error "Timeout: Xvfb failed to start properly. Exiting."
    exit 1
fi
log_success "Xvfb started successfully."

# Check which gource release is chosen
if [ "${USE_GOURCE_NIGHTLY}" = "1" ]; then
    export GOURCE_EXEC='gource_nightly'
    log_warn "Using `${GOURCE_EXEC} -h | head -n 1` Nightly Release"
    export USE_NIGHTLY=1
else
    export GOURCE_EXEC='gource'
    log_notice "Using `${GOURCE_EXEC} -h | head -n 1` Stable Release "
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
    T_COUNT=0
    S_COUNT=0
    LOGS=""
    for DIRECTORY in `find /visualization/git_repo -maxdepth 1 -mindepth 1 -type d -printf '%f\n'`
    do
        log_notice "Checking ${DIRECTORY}... "
        if [ ! -d /visualization/git_repo/${DIRECTORY}/.git ]; then
            log_warn "/visualization/git_repo/${DIRECTORY} is not a git repo, skipping..."
            continue
        fi
        if [ "${RECURSE_SUBMODULES}" = "1" ]; then
            log_info "Recursing through submodules in ${DIRECTORY}"
            SUBMOD_PATHS=()
            cd /visualization/git_repo/${DIRECTORY} && git submodule foreach --recursive '( echo "SUBMOD_PATHS+=($displaypath)" >> /visualization/submods.bash )'
            cd /visualization
            if [ ! -f /visualization/submods.bash ]; then
                log_warn "No submodules found in ${DIRECTORY}. Continuing..."
            else
                . submods.bash
                rm  submods.bash
            fi
            SUBMOD_PATHS+=('') # include parent of course
            for SUBMOD_PATH in "${SUBMOD_PATHS[@]}"; do
                ((++T_COUNT))
                set -e
                ${GOURCE_EXEC} --output-custom-log development${T_COUNT}.log /visualization/git_repo/${DIRECTORY}/${SUBMOD_PATH}
                set +e
                if [ "${SUBMOD_PATH}" != "" ]; then
                    sed -i -r "s#(.+)\|#\1|/${DIRECTORY}/${SUBMOD_PATH}#" development${T_COUNT}.log
                    ((S_COUNT++))
                else
                    sed -i -r "s#(.+)\|#\1|/${DIRECTORY}#" development${T_COUNT}.log
                fi

                LOGS="${LOGS} development${T_COUNT}.log"
            done
        else
            ((++T_COUNT))
            set -e
            ${GOURCE_EXEC} --output-custom-log development${T_COUNT}.log /visualization/git_repo/${DIRECTORY}
            set +e
            sed -i -r "s#(.+)\|#\1|/${DIRECTORY}#" development${T_COUNT}.log
            LOGS="${LOGS} development${T_COUNT}.log"
        fi
    done
    log_success "Processed $(($T_COUNT-$S_COUNT)) repos and ${S_COUNT} submodules."
    cat ${LOGS} | sort -n > development.log
    rm ${LOGS}
else
    # Assume this is a single-repo setup
    log_info "Detected single-repo input."
    S_COUNT=0
    if [ "${RECURSE_SUBMODULES}" = "1" ]; then
        log_info "Recursing through submodules."
        SUBMOD_PATHS=()
        cd /visualization/git_repo && git submodule foreach --recursive '( echo "SUBMOD_PATHS+=($displaypath)" >> /visualization/submods.bash )'
        cd /visualization
        if [ ! -f /visualization/submods.bash ]; then
            log_warn "No submodules found. Continuing..."
        else
            . submods.bash
            rm  submods.bash
        fi
        LOGS=""
        SUBMOD_PATHS+=('') # include parent of course
        for SUBMOD_PATH in "${SUBMOD_PATHS[@]}"; do
            ((++S_COUNT))
            set -e
            ${GOURCE_EXEC} --output-custom-log development${S_COUNT}.log /visualization/git_repo/${SUBMOD_PATH}
            set +e
            if [ "${SUBMOD_PATH}" != "" ]; then
                sed -i -r "s#(.+)\|#\1|/${SUBMOD_PATH}#" development${S_COUNT}.log
            fi
            LOGS="${LOGS} development${S_COUNT}.log"
        done
        ((--S_COUNT)) # Account for repo itself
        cat ${LOGS} | sort -n > development.log
        rm ${LOGS}
    else
        # Single repo no submods - simple case.
        set -e
        ${GOURCE_EXEC} --output-custom-log development.log /visualization/git_repo
        set +e
    fi
    log_success "Processed 1 repo and ${S_COUNT} submodules."
fi
log_info "Git Logs Parsed."

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
cp /visualization/html/processing_gource.html /visualization/html/index.html
lighttpd -f /visualization/runtime/http.conf -D &
httpd_pid="$!"
trap "echo 'Stopping proccesses PIDs: ($xvfb_pid, $http_pid)'; kill -SIGTERM $xvfb_pid $httpd_pid" SIGINT SIGTERM

# Run the visualization
if [ -n "${TEMPLATE}" ]; then
    if [ "${TEMPLATE}" = "border" ]; then
        log_info "Using border template..."
        /visualization/runtime/templates/border_template.sh
    else
        log_error "Unknown template option ${TEMPLATE}"
        exit 1
    fi
else
    log_info "Using no template..."
    /visualization/runtime/templates/no_template.sh
fi

if [ -f /visualization/video/output.mp4 ]; then
    log_success "Visualization process is complete."
else
    log_error "Visualization process failed."
fi

if [ ! "${USE_LOCAL_OUTPUT}" = "1" ]; then
    # Wait for httpd process to end.
    while kill -0 $httpd_pid >/dev/null 2>&1; do
        wait
    done
else
    chmod 666 /visualization/video/output.mp4
fi

# Exit
echo "Exiting"
exit
