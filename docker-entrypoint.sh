#!/bin/bash

# Start Xvfb
echo "Starting Xvfb"
Xvfb :99 -ac -screen 0 $XVFB_WHD -nolisten tcp &
xvfb_pid="$!"

# possible race condition waiting for Xvfb.
sleep 5

# Check if repo exists
if [ ! -d /visualization/git_repo ]
then
	echo "Error: git repo not found: /visualization/git_repo does not exist."
	exit 1
fi
echo "Using volume mounted git repo"

# Check if this is a single or multi repo
if [ ! -d /visualization/git_repo/.git ]; then
	# Assume this is a multi-repo setup
	X=0
	LOGS=""
	for DIRECTORY in `find /visualization/git_repo -maxdepth 1 -mindepth 1 -type d -printf '%f\n'`
	do
		((X++))
		gource --output-custom-log development${X}.log /visualization/git_repo/${DIRECTORY}
		sed -i -r "s#(.+)\|#\1|/${DIRECTORY}#" development${X}.log
		LOGS="${LOGS} development${X}.log"
	done
	cat ${LOGS} | sort -n > development.log
	rm ${LOGS}
	# Enable settings specifically tailored for multirepo representation
	export MULTIREPO=1
else
	# Assume this is a single-repo setup
	# Generate a gource log file.
	if [ "${RECURSE_SUBMODULES}" = "1" ]; then
		echo "Recursing through submodules."
		cd /visualization/git_repo && git submodule foreach --recursive '( echo $path; echo "SUBMOD_PATHS+=($path)" >> /visualization/submods.bash )'
		cd /visualization
		. submods.bash
		rm submods.bash
		X=0
		LOGS=""
		SUBMOD_PATHS+=('') # include parent of course
		for path in "${SUBMOD_PATHS[@]}"; do
			((X++))
			gource --output-custom-log development${X}.log /visualization/git_repo/${path}
			if [ "${path}" != "" ]; then
				sed -i -r "s#(.+)\|#\1|/${path}#" development${X}.log
			fi
			LOGS="${LOGS} development${X}.log"
		done
		cat ${LOGS} | sort -n > development.log
		rm ${LOGS}
	else
		gource --output-custom-log development.log /visualization/git_repo
	fi
fi


# Check for captions
if [ -f /visualization/captions.txt ]; then
	echo "Using captions file"
	export USE_CAPTIONS=1
fi

# Set proper env variables if we have a logo.
if [ "${LOGO_URL}" != "" ]; then
	wget -O ./logo.image ${LOGO_URL}
	convert -geometry x160 ./logo.image ./logo.image
	if [ "$?" = 0 ]; then
		echo "Using logo from: ${LOGO_URL}"
		export LOGO=" -i ./logo.image "
		if [[ "${TEMPLATE}" == "border" ]]; then
			export LOGO_FILTER_GRAPH=";[with_date][2:v]overlay=main_w-overlay_w-40:main_h-overlay_h-40[with_logo]"
			export FILTER_GRAPH_MAP=" -map [with_logo] "
		else
			export LOGO_FILTER_GRAPH="[1:v]overlay=main_w-overlay_w-40:main_h-overlay_h-40[with_logo]"
			export FILTER_GRAPH_MAP=" -map [with_logo] "
		fi
	else
		if [[ "${TEMPLATE}" == "border" ]]; then
			echo "Not using a logo."
			export FILTER_GRAPH_MAP=" -map [with_date] "
		else
			export FILTER_GRAPH_MAP=""
		fi
	fi
else
	if [[ "${TEMPLATE}" == "border" ]]; then
		echo "Not using a logo."
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
	/visualization/border_template.sh
else
	/visualization/no_template.sh
fi

echo "Visualization process is complete"

# Wait for httpd process to end.
while kill -0 $httpd_pid >/dev/null 2>&1; do
	wait
done

# Exit
echo "Exiting"
exit
