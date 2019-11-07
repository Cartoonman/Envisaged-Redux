#!/bin/bash

# Copyright (c) 2019 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: MIT

COLOR_RED='\033[0;31m'
COLOR_MAGENTA='\033[0;95m'
COLOR_CYAN='\033[0;96m'
COLOR_GREEN='\033[0;92m'
COLOR_YELLOW='\033[0;93m'
NO_COLOR='\033[0m'

# Start Xvfb
echo -e "${COLOR_YELLOW}Starting Xvfb${NO_COLOR}"
Xvfb :99 -ac -screen 0 $XVFB_WHD -nolisten tcp &
xvfb_pid="$!"

# possible race condition waiting for Xvfb.
sleep 5

# Check if repo exists
if [ ! -d /visualization/git_repo ]
then
	echo -e "${COLOR_RED}Error: git repo not found: /visualization/git_repo does not exist.${NO_COLOR}"
	exit 1
fi

# Check if this is a single or multi repo
if [ ! -d /visualization/git_repo/.git ]; then
	# Assume this is a multi-repo setup
	echo -e "${COLOR_YELLOW}Detected potential multi-repo input. Assuming this is a multi-repo directory.${NO_COLOR}"
	X=0
	LOGS=""
	for DIRECTORY in `find /visualization/git_repo -maxdepth 1 -mindepth 1 -type d -printf '%f\n'`
	do
		echo -e "${COLOR_YELLOW}Checking ${DIRECTORY}... ${NO_COLOR}"
		if [ ! -d /visualization/git_repo/${DIRECTORY}/.git ]; then
			echo -e "${COLOR_MAGENTA}/visualization/git_repo/${DIRECTORY} is not a git repo, skipping...${NO_COLOR}"
			continue
		fi
		if [ "${RECURSE_SUBMODULES}" = "1" ]; then
			echo -e "${COLOR_YELLOW}Recursing through submodules in ${DIRECTORY}${NO_COLOR}"
			SUBMOD_PATHS=()
			cd /visualization/git_repo/${DIRECTORY} && git submodule foreach --recursive '( echo "SUBMOD_PATHS+=($displaypath)" >> /visualization/submods.bash )'
			cd /visualization
			if [ ! -f /visualization/submods.bash ]; then
				echo -e "${COLOR_MAGENTA}No submodules found in ${DIRECTORY}. Continuing...${NO_COLOR}"
			else
				. submods.bash
				rm  submods.bash
			fi
			SUBMOD_PATHS+=('') # include parent of course
			for path in "${SUBMOD_PATHS[@]}"; do
				((X++))
				set -e
				gource --output-custom-log development${X}.log /visualization/git_repo/${DIRECTORY}/${path}
				set +e
				if [ "${path}" != "" ]; then
					sed -i -r "s#(.+)\|#\1|/${DIRECTORY}/${path}#" development${X}.log
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
	cat ${LOGS} | sort -n > development.log
	rm ${LOGS}
	echo -e "${COLOR_CYAN}Git Logs Parsed.${NO_COLOR}"
	# Enable settings specifically tailored for multirepo representation
	export MULTIREPO=1
else
	# Assume this is a single-repo setup
	# Generate a gource log file.
	echo -e "${COLOR_YELLOW}Detected single-repo input.${NO_COLOR}"
	if [ "${RECURSE_SUBMODULES}" = "1" ]; then
		# Single repo w/ submods
		echo -e "${COLOR_YELLOW}Recursing through submodules.${NO_COLOR}"
		SUBMOD_PATHS=()
		cd /visualization/git_repo && git submodule foreach --recursive '( echo "SUBMOD_PATHS+=($displaypath)" >> /visualization/submods.bash )'
		cd /visualization
		if [ ! -f /visualization/submods.bash ]; then
			echo -e "${COLOR_MAGENTA}No submodules found. Continuing...${NO_COLOR}"
		else
			. submods.bash
			rm  submods.bash
		fi
		X=0
		LOGS=""
		SUBMOD_PATHS+=('') # include parent of course
		for path in "${SUBMOD_PATHS[@]}"; do
			((X++))
			set -e
			gource --output-custom-log development${X}.log /visualization/git_repo/${path}
			set +e
			if [ "${path}" != "" ]; then
				sed -i -r "s#(.+)\|#\1|/${path}#" development${X}.log
			fi
			LOGS="${LOGS} development${X}.log"
		done
		cat ${LOGS} | sort -n > development.log
		rm ${LOGS}
	else
		# Single repo no submods - simple case.
		set -e
		gource --output-custom-log development.log /visualization/git_repo
		set +e
	fi
	echo -e "${COLOR_CYAN}Git Logs Parsed.${NO_COLOR}"
fi

# Check for avatar directory mount.
if [ -d /visualization/avatars ]; then
	echo -e "${COLOR_CYAN}Using avatars directory${NO_COLOR}"
	export USE_AVATARS=1
fi

# Check for captions
if [ -f /visualization/captions.txt ]; then
	echo -e "${COLOR_CYAN}Using captions file${NO_COLOR}"
	export USE_CAPTIONS=1
fi

# Check for logo
if [ -f /visualization/logo.image ]; then
	echo -e "${COLOR_YELLOW}Possible logo file detected. Attempting to transform...${NO_COLOR}"
	set -e
	convert -geometry x160 /visualization/logo.image /visualization/logo_txfrmed.image
	set +e
	echo -e "${COLOR_CYAN}Success. Using logo file${NO_COLOR}"
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
	echo -e "${COLOR_CYAN}Using border template...${NO_COLOR}"
	/visualization/border_template.sh
else
	echo -e "${COLOR_CYAN}Using no template...${NO_COLOR}"
	/visualization/no_template.sh
fi

echo -e "${COLOR_GREEN}Visualization process is complete${NO_COLOR}"

# Wait for httpd process to end.
while kill -0 $httpd_pid >/dev/null 2>&1; do
	wait
done

# Exit
echo "Exiting"
exit
