#!/bin/bash

# Copyright (c) 2019 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: MIT

DIR="${BASH_SRC%/*}"
if [[ ! -d  "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/common.bash"

# Predefined resolutions and settings.
if [[ "${VIDEO_RESOLUTION}" == "2160p" ]]; then
	GOURCE_RES="3840x2160"
	log_info "Using 2160p settings. Output will be 3840x2160 at ${FPS}fps."
elif [[ "${VIDEO_RESOLUTION}" == "1440p" ]]; then
	GOURCE_RES="2560x1440"
	log_info "Using 1440p settings. Output will be 2560x1440 at ${FPS}fps."
elif [[ "${VIDEO_RESOLUTION}" == "1080p" ]]; then
	GOURCE_RES="1920x1080"
	log_info "Using 1080p settings. Output will be 1920x1080 at ${FPS}fps."
elif [[ "${VIDEO_RESOLUTION}" == "720p" ]]; then
	GOURCE_RES="1280x720"
	log_info "Using 720p settings. Output will be 1280x720 at ${FPS}fps."
elif [[ "${VIDEO_RESOLUTION}" == "480p" ]]; then
	GOURCE_RES="854x480"
	log_info "Using 720p settings. Output will be 1280x720 at ${FPS}fps."
else
	log_error "${VIDEO_RESOLUTION} is not a valid/supported video resolution."
	exit 1
fi

# Default map
PRIMARY_MAP_LABEL="[default]"
if [[ "${INVERT_COLORS}" == "true" ]]; then
	INVERT_FILTER=";${PRIMARY_MAP_LABEL}lutrgb=r=negval:g=negval:b=negval[invert]"
	PRIMARY_MAP_LABEL="[invert]"
fi

if [ "${LOGO}" != "" ]; then
	LOGO_FILTER_GRAPH=";${PRIMARY_MAP_LABEL}[1:v]overlay=main_w-overlay_w-40:main_h-overlay_h-40[with_logo]"
	PRIMARY_MAP_LABEL="[with_logo]"
fi

if [ "${LIVE_PREVIEW}" = "1" ]; then
	LP_FPS=$((${FPS} / ${PREVIEW_SLOWDOWN_FACTOR}))
	LIVE_PREVIEW_SPLITTER=";${PRIMARY_MAP_LABEL}split[original_feed][time_scaler];[time_scaler]setpts=${PREVIEW_SLOWDOWN_FACTOR}*PTS[live_preview]"
	PRIMARY_MAP_LABEL="[original_feed]"
	LIVE_PREVIEW_ARGS=" -map [live_preview] -c:v libx264 -pix_fmt yuv420p -maxrate 40M -bufsize 2M \
		-profile:v high -level:v 5.2 -y -r ${LP_FPS} -preset ultrafast -crf 1 \
		-tune zerolatency -x264-params keyint=$((${LP_FPS} * 3)):min-keyint=${LP_FPS} \
		-vsync vfr -hls_flags independent_segments+delete_segments -hls_allow_cache 1 \
		-hls_time 1 -hls_list_size 10 -start_number 0 ./html/preview.m3u8"
fi

# Create our temp directory
mkdir -p ./tmp

# Create our named pipes.
mkfifo ./tmp/gource.pipe

if [ "${GOURCE_START_DATE}" != "" ]; then
	GOURCE_START_DATE="--start-date ${GOURCE_START_DATE}"
fi
if [ "${GOURCE_STOP_DATE}" != "" ]; then
	GOURCE_STOP_DATE="--stop-date ${GOURCE_STOP_DATE}"
fi
if [ "${GOURCE_START_POSITION}" != "" ]; then
	GOURCE_START_POSITION="--start-position ${GOURCE_START_POSITION}"
fi
if [ "${GOURCE_STOP_POSITION}" != "" ]; then
	GOURCE_STOP_POSITION="--stop-position ${GOURCE_STOP_POSITION}"
fi
if [ "${GOURCE_STOP_AT_TIME}" != "" ]; then
	GOURCE_STOP_AT_TIME="--stop-at-time ${GOURCE_STOP_AT_TIME}"
fi

if [ "${GOURCE_HIGHLIGHT_ALL_USERS}" = "true" ]; then
	GOURCE_HIGHLIGHT_ALL_USERS="--highlight-users"
else
	GOURCE_HIGHLIGHT_ALL_USERS=""
fi

# Avatars
if [ "${USE_AVATARS}" = "1" ]; then
	GOURCE_USER_AVATARS="--user-image-dir /visualization/avatars"
fi


# Captions
GOURCE_CAPTIONS=""
if [ "${USE_CAPTIONS}" = "1" ]; then
	GOURCE_CAPTIONS=" --caption-file /visualization/captions.txt \
	--caption-size ${GOURCE_CAPTION_SIZE} \
	--caption-colour ${GOURCE_CAPTION_COLOR} \
	--caption-duration ${GOURCE_CAPTION_DURATION} "
fi

# Check for nightly release args
if [ "${USE_NIGHTLY}" = "1" ]; then
	# Check nightly args (0.50)
	if [ "${GOURCE_FILE_EXT_FALLBACK}" = "true" ]; then
		GOURCE_NIGHTLY_ARGS+=" --file-extension-fallback "
	fi
fi

# Check hide items and apply
if [ "${GOURCE_HIDE_ITEMS}" !=  "" ]; then
	GOURCE_HIDE_ITEMS_ARG = "--hide ${GOURCE_HIDE_ITEMS}"
fi



log_notice "Starting Gource primary with title: ${GOURCE_TITLE}"
${GOURCE_EXEC} \
	${GOURCE_START_DATE} \
	${GOURCE_STOP_DATE} \
	${GOURCE_START_POSITION} \
	${GOURCE_STOP_POSITION} \
	${GOURCE_STOP_AT_TIME} \
	${GOURCE_CAPTIONS} \
	${GOURCE_USER_AVATARS} \
	${GOURCE_NIGHTLY_ARGS} \
	--auto-skip-seconds ${GOURCE_AUTO_SKIP_SECONDS} \
	--seconds-per-day ${GOURCE_SECONDS_PER_DAY} \
	--user-scale ${GOURCE_USER_SCALE} \
	--time-scale ${GOURCE_TIME_SCALE} \
	--file-idle-time ${GOURCE_FILE_IDLE_TIME} \
	--max-files ${GOURCE_MAX_FILES} \
	--max-file-lag ${GOURCE_MAX_FILE_LAG} \
	--title "${GOURCE_TITLE}" \
	--background-colour ${GOURCE_BACKGROUND_COLOR} \
	--font-colour ${GOURCE_TITLE_TEXT_COLOR} \
	--camera-mode ${GOURCE_CAMERA_MODE} \
	--date-format "${GOURCE_DATE_FORMAT}" \
	${GOURCE_HIDE_ITEMS_ARG} \
	--font-size ${GOURCE_TITLE_FONT_SIZE} \
	--dir-name-depth ${GOURCE_DIR_DEPTH} \
	--filename-time ${GOURCE_FILENAME_TIME} \
	--max-user-speed ${GOURCE_MAX_USER_SPEED} \
	--bloom-multiplier ${GOURCE_BLOOM_MULTIPLIER} \
	--bloom-intensity ${GOURCE_BLOOM_INTENSITY} \
	${GOURCE_HIGHLIGHT_ALL_USERS} \
	--multi-sampling \
	--padding ${GOURCE_PADDING} \
	--${GOURCE_RES} \
	--stop-at-end \
	./development.log \
	-r ${FPS} \
	-o - >./tmp/gource.pipe &
log_success "Gource primary started."

# Start ffmpeg 
log_notice "Rendering video pipe.."
mkdir -p ./video
# [0:v]: gource, [1:v]: logo
ffmpeg -y -r ${FPS} -f image2pipe -probesize 100M -i ./tmp/gource.pipe \
			${LOGO} \
			-filter_complex "[0:v]select[default]${INVERT_FILTER}${LOGO_FILTER_GRAPH}${LIVE_PREVIEW_SPLITTER}" -map ${PRIMARY_MAP_LABEL} \
			-vcodec libx265 -pix_fmt yuv420p -crf ${H265_CRF} -preset ${H265_PRESET} ./video/output.mp4 ${LIVE_PREVIEW_ARGS}

log_success "FFmpeg video render completed!"
# Remove our temporary files.
echo "Removing temporary files."
rm -rf ./tmp

# Update html and link new video.
filesize="$(du -sh /visualization/video/output.mp4 | cut -f 1)"
printf "$(cat /visualization/html/completed.html)" $filesize >/visualization/html/index.html
ln -sf /visualization/video/output.mp4 /visualization/html/output.mp4
