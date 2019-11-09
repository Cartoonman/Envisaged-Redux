#!/bin/bash

# Copyright (c) 2019 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: MIT

DIR="${BASH_SRC%/*}"
if [[ ! -d  "${DIR}" ]]; then DIR="${PWD}"; fi
. "${DIR}/common.bash"

# Start Xvfb
log_notice "Starting Xvfb..."
Xvfb :99 -ac -screen 0 $XVFB_WHD -nocursor -noreset -nolisten tcp &
xvfb_pid="${!}"
RET_CODE=9999
WATCH_START=${SECONDS}
while [ ${RET_CODE} -ne 0 ] && [ $(( ${SECONDS} - ${WATCH_START} )) -le 60 ]; do
        xdpyinfo -display :99 &> /dev/null
        RET_CODE=${?}
done
if [ $(( ${SECONDS} - ${WATCH_START} )) -gt 60 ]; then
	log_error "Timeout: Xvfb failed to start properly. Exiting."
	exit 1
fi
log_success "Xvfb started successfully."

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
	X=0
	Y=0
	LOGS=""
	for DIRECTORY in `find /visualization/git_repo -maxdepth 1 -mindepth 1 -type d -printf '%f\n'`
	do
		log_notice "Checking ${DIRECTORY}... "
		if [ ! -d /visualization/git_repo/${DIRECTORY}/.git ]; then
			log_warn "/visualization/git_repo/${DIRECTORY} is not a git repo, skipping..."
			continue
		fi
		if [ "${RECURSE_SUBMODULES}" = "true" ]; then
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
				((X++))
				set -e
				gource --output-custom-log development${X}.log /visualization/git_repo/${DIRECTORY}/${SUBMOD_PATH}
				set +e
				if [ "${SUBMOD_PATH}" != "" ]; then
					sed -i -r "s#(.+)\|#\1|/${DIRECTORY}/${SUBMOD_PATH}#" development${X}.log
					((Y++))
				else
					sed -i -r "s#(.+)\|#\1|/${DIRECTORY}#" development${X}.log
				fi

				LOGS="${LOGS} development${X}.log"
			done
		else
			((X++))
			set -e
			gource --output-custom-log development${X}.log /visualization/git_repo/${DIRECTORY}
			set +e
			sed -i -r "s#(.+)\|#\1|/${DIRECTORY}#" development${X}.log
			LOGS="${LOGS} development${X}.log"
		fi
	done
	log_success "Processed $(($X-$Y)) repos and $Y submodules."
	cat ${LOGS} | sort -n > development.log
	rm ${LOGS}
	# Enable settings specifically tailored for multirepo representation
	export MULTIREPO=1
else
	# Assume this is a single-repo setup
	log_info "Detected single-repo input."
	Y=0
	if [ "${RECURSE_SUBMODULES}" = "true" ]; then
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
			((Y++))
			set -e
			gource --output-custom-log development${Y}.log /visualization/git_repo/${SUBMOD_PATH}
			set +e
			if [ "${SUBMOD_PATH}" != "" ]; then
				sed -i -r "s#(.+)\|#\1|/${SUBMOD_PATH}#" development${Y}.log
			fi
			LOGS="${LOGS} development${Y}.log"
		done
		((--Y))
		cat ${LOGS} | sort -n > development.log
		rm ${LOGS}
	else
		# Single repo no submods - simple case.
		set -e
		gource --output-custom-log development.log /visualization/git_repo
		set +e
	fi
	log_success "Processed 1 repo and $Y submodules."
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
	log_info "Success. Using logo file"
	export LOGO=" -i ./logo_txfrmed.image "
	if [[ "${TEMPLATE}" == "border" ]]; then
		export LOGO_FILTER_GRAPH=";[with_date][2:v]overlay=main_w-overlay_w-40:main_h-overlay_h-40[with_logo]"
		export FILTER_GRAPH_MAP=" -map [with_logo] "
	else
		export LOGO_FILTER_GRAPH="[1:v]overlay=main_w-overlay_w-40:main_h-overlay_h-40[with_logo]"
		export FILTER_GRAPH_MAP=" -map [with_logo] "
	fi
else
	if [[ "${TEMPLATE}" == "border" ]]; then
		export FILTER_GRAPH_MAP=" -map [with_date] "
	else
		export FILTER_GRAPH_MAP=""
	fi
fi

# Start the httpd to serve the video.
cp /visualization/html/processing_gource.html /visualization/html/index.html
lighttpd -f http.conf -D &
httpd_pid="$!"
trap "echo 'Stopping proccesses PIDs: ($xvfb_pid, $http_pid)'; kill -SIGTERM $xvfb_pid $httpd_pid" SIGINT SIGTERM

# Run the visualization
if [[ "${TEMPLATE}" == "border" ]]; then
	log_info "Using border template..."
	/visualization/border_template.sh
else
	log_info "Using no template..."
	/visualization/no_template.sh
fi

log_success "Visualization process is complete"

# Wait for httpd process to end.
while kill -0 $httpd_pid >/dev/null 2>&1; do
	wait
done

# Exit
echo "Exiting"
exit
