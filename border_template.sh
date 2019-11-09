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
	GOURCE_RES="3500x1940"
	OVERLAY_RES="1920x1080"
	GOURCE_PAD="3520:1960:3520:1960:#313133"
	KEY_CROP="320:1860:0:0"
	KEY_PAD="320:1960:0:0:#202021"
	DATE_CROP="3520:200:640:0"
	DATE_PAD="3840:200:320:200:#202021"
	OUTPUT_RES="3840:2160"
	echo "Using 2160p settings. Output will be 3840x2160 at ${FPS}fps."
elif [[ "${VIDEO_RESOLUTION}" == "1440p" ]]; then
	GOURCE_RES="2333x1293"
	OVERLAY_RES="1920x1080"
	GOURCE_PAD="2346:1306:2346:1306:#313133"
	KEY_CROP="214:1240:0:0"
	KEY_PAD="214:1306:0:0:#202021"
	DATE_CROP="2346:134:426:0"
	DATE_PAD="2560:134:214:134:#202021"
	OUTPUT_RES="2560:1440"
	echo "Using 1440p settings. Output will be 2560x1440 at ${FPS}fps."
elif [[ "${VIDEO_RESOLUTION}" == "1080p" ]]; then
	GOURCE_RES="1750x970"
	OVERLAY_RES="1920x1080"
	GOURCE_PAD="1760:980:1760:980:#313133"
	KEY_CROP="160:930:0:0"
	KEY_PAD="160:980:0:0:#202021"
	DATE_CROP="1760:100:320:0"
	DATE_PAD="1920:100:160:100:#202021"
	OUTPUT_RES="1920:1080"
	echo "Using 1080p settings. Output will be 1920x1080 at ${FPS}fps."
elif [[ "${VIDEO_RESOLUTION}" == "720p" ]]; then
	GOURCE_RES="1116x646"
	OVERLAY_RES="1280x720"
	GOURCE_PAD="1128:653:1128:653:#313133"
	KEY_CROP="152:590:0:0"
	KEY_PAD="152:653:0:0:#202021"
	DATE_CROP="1128:67:152:0"
	DATE_PAD="1280:67:152:67:#202021"
	OUTPUT_RES="1280:720"
	echo "Using 720p settings. Output will be 1280x720 at ${FPS}fps."
elif [[ "${VIDEO_RESOLUTION}" == "480p" ]]; then
	GOURCE_RES="700x410"
	OVERLAY_RES="854x480"
	GOURCE_PAD="708:420:708:420:#313133"
	KEY_CROP="146:390:0:0"
	KEY_PAD="146:420:0:0:#202021"
	DATE_CROP="708:60:146:0"
	DATE_PAD="854:60:146:60:#202021"
	OUTPUT_RES="854:480"
	echo "Using 480p settings. Output will be 854x480 at ${FPS}fps."
fi

if [[ "${INVERT_COLORS}" == "true" ]]; then
	GOURCE_FILTERS="${GOURCE_FILTERS},lutrgb=r=negval:g=negval:b=negval"
fi

# Create our temp directory
mkdir -p ./tmp

# Create our named pipes.
mkfifo ./tmp/gource.pipe
mkfifo ./tmp/overlay.pipe

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

# Check if this is multirepo
if [ "${MULTIREPO}" = "1" ]; then
	# if something needs to be done, do it here.
	:
fi

# Start Gource for visualization.
echo -e "${COLOR_GREEN}Starting Gource, using title: ${GOURCE_TITLE}${NO_COLOR}"
gource \
	${GOURCE_START_DATE} \
	${GOURCE_STOP_DATE} \
	${GOURCE_START_POSITION} \
	${GOURCE_STOP_POSITION} \
	${GOURCE_STOP_AT_TIME} \
	${GOURCE_CAPTIONS} \
	${GOURCE_USER_AVATARS} \
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
	--hide ${GOURCE_HIDE_ITEMS} \
	--font-size ${GOURCE_TITLE_FONT_SIZE} \
	--dir-name-depth ${GOURCE_DIR_DEPTH} \
	--filename-time ${GOURCE_FILENAME_TIME} \
	--max-user-speed ${GOURCE_MAX_USER_SPEED} \
	--bloom-multiplier 1.2 \
	--highlight-users \
	--multi-sampling \
	--padding ${GOURCE_PADDING} \
	--${GOURCE_RES} \
	--stop-at-end \
	./development.log \
	-r ${FPS} \
	-o - >./tmp/gource.pipe &

# Start Gource for the overlay elements.
echo -e "${COLOR_GREEN}Starting Gource for overlay components${NO_COLOR}"
gource \
	${GOURCE_START_DATE} \
	${GOURCE_STOP_DATE} \
	${GOURCE_START_POSITION} \
	${GOURCE_STOP_POSITION} \
	${GOURCE_STOP_AT_TIME} \
	--seconds-per-day ${GOURCE_SECONDS_PER_DAY} \
	--user-scale ${GOURCE_USER_SCALE} \
	--time-scale ${GOURCE_TIME_SCALE} \
	--auto-skip-seconds ${GOURCE_AUTO_SKIP_SECONDS} \
	--file-idle-time ${GOURCE_FILE_IDLE_TIME} \
	--key \
	--transparent \
	--background-colour 202021 \
	--font-colour ${GOURCE_DATE_FONT_COLOR} \
	--camera-mode overview \
	--date-format "${GOURCE_DATE_FORMAT}" \
	--hide bloom,dirnames,files,filenames,mouse,root,tree,users,usernames \
	--font-size ${GOURCE_DATE_FONT_SIZE} \
	--${OVERLAY_RES} \
	--stop-at-end \
	--multi-sampling \
	--dir-name-depth ${GOURCE_DIR_DEPTH} \
	--filename-time ${GOURCE_FILENAME_TIME} \
	--max-user-speed ${GOURCE_MAX_USER_SPEED} \
	./development.log \
	-r ${FPS} \
	-o - >./tmp/overlay.pipe &

# Start ffmpeg to merge the two video outputs.
echo -e "${COLOR_GREEN}Combining videos pipes and rendering...${NO_COLOR}"
mkdir -p ./video
ffmpeg -y -r ${FPS} -f image2pipe -probesize 100M -i ./tmp/gource.pipe \
	-y -r ${FPS} -f image2pipe -probesize 100M -i ./tmp/overlay.pipe \
	${LOGO} \
	-filter_complex "[0:v]pad=${GOURCE_PAD}${GOURCE_FILTERS}[center];\
                         [1:v]scale=${OUTPUT_RES}[key_scale];\
                         [1:v]scale=${OUTPUT_RES}[date_scale];\
                         [key_scale]crop=${KEY_CROP},pad=${KEY_PAD}[key];\
                         [date_scale]crop=${DATE_CROP},pad=${DATE_PAD}[date];\
                         [key][center]hstack[with_key];\
                         [date][with_key]vstack[with_date]${LOGO_FILTER_GRAPH}${GLOBAL_FILTERS}" ${FILTER_GRAPH_MAP} \
	-vcodec libx265 -pix_fmt yuv420p -crf ${H265_CRF} -preset ${H265_PRESET} ./video/output.mp4

# Remove our temporary files.
echo -e "${COLOR_YELLOW}Removing temporary files.${NO_COLOR}"
rm -rf ./tmp

# Update html and link new video.
filesize="$(du -sh /visualization/video/output.mp4 | cut -f 1)"
printf "$(cat /visualization/html/completed.html)" $filesize >/visualization/html/index.html
ln -sf /visualization/video/output.mp4 /visualization/html/output.mp4
