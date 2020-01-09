#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: Apache-2.0 AND MIT

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. "${DIR}/../common/common_templates.bash"

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
    log_info "Using 2160p settings. Output will be 3840x2160 at ${FPS}fps."
elif [[ "${VIDEO_RESOLUTION}" == "1440p" ]]; then
    GOURCE_RES="2333x1293"
    OVERLAY_RES="1920x1080"
    GOURCE_PAD="2346:1306:2346:1306:#313133"
    KEY_CROP="214:1240:0:0"
    KEY_PAD="214:1306:0:0:#202021"
    DATE_CROP="2346:134:426:0"
    DATE_PAD="2560:134:214:134:#202021"
    OUTPUT_RES="2560:1440"
    log_info "Using 1440p settings. Output will be 2560x1440 at ${FPS}fps."
elif [[ "${VIDEO_RESOLUTION}" == "1080p" ]]; then
    GOURCE_RES="1750x970"
    OVERLAY_RES="1920x1080"
    GOURCE_PAD="1760:980:1760:980:#313133"
    KEY_CROP="160:930:0:0"
    KEY_PAD="160:980:0:0:#202021"
    DATE_CROP="1760:100:320:0"
    DATE_PAD="1920:100:160:100:#202021"
    OUTPUT_RES="1920:1080"
    log_info "Using 1080p settings. Output will be 1920x1080 at ${FPS}fps."
elif [[ "${VIDEO_RESOLUTION}" == "720p" ]]; then
    GOURCE_RES="1116x646"
    OVERLAY_RES="1280x720"
    GOURCE_PAD="1128:653:1128:653:#313133"
    KEY_CROP="152:590:0:0"
    KEY_PAD="152:653:0:0:#202021"
    DATE_CROP="1128:67:152:0"
    DATE_PAD="1280:67:152:67:#202021"
    OUTPUT_RES="1280:720"
    log_info "Using 720p settings. Output will be 1280x720 at ${FPS}fps."
elif [[ "${VIDEO_RESOLUTION}" == "480p" ]]; then
    GOURCE_RES="700x410"
    OVERLAY_RES="854x480"
    GOURCE_PAD="708:420:708:420:#313133"
    KEY_CROP="146:390:0:0"
    KEY_PAD="146:420:0:0:#202021"
    DATE_CROP="708:60:146:0"
    DATE_PAD="854:60:146:60:#202021"
    OUTPUT_RES="854:480"
    log_info "Using 480p settings. Output will be 854x480 at ${FPS}fps."
else
    log_error "${VIDEO_RESOLUTION} is not a valid/supported video resolution."
    exit 1
fi

# Generate ffmpeg flags
LOGO_FFMPEG_LABEL="[2:v]" && gen_ffmpeg_flags

# Create our temp directory
mkdir -p /visualization/tmp

# Create our named pipes.
mkfifo /visualization/tmp/gource.pipe
mkfifo /visualization/tmp/overlay.pipe


# Generate args for Primary Gource
GOURCE_FONT_SIZE="${GOURCE_BORDER_TITLE_FONT_SIZE}"
GOURCE_FONT_COLOR="${GOURCE_BORDER_TITLE_TEXT_COLOR}"
GOURCE_HIDE_ITEMS="date,mouse,${GOURCE_HIDE_ITEMS}"
GOURCE_SHOW_KEY=0

gen_gource_args
GOURCE_PRIMARY_ARGS=("${GOURCE_ARG_ARRAY[@]}")



# Generate args for Secondary Gource
GOURCE_FONT_SIZE="${GOURCE_BORDER_TITLE_FONT_SIZE}"
GOURCE_FONT_COLOR="${GOURCE_BORDER_DATE_FONT_COLOR}"
GOURCE_HIDE_ITEMS="bloom,dirnames,files,filenames,mouse,root,tree,users,usernames"
GOURCE_SHOW_KEY=1
unset GOURCE_BACKGROUND_COLOR

gen_gource_args
GOURCE_SECONDARY_ARGS=("${GOURCE_ARG_ARRAY[@]}")

# Start Gource for visualization.
log_notice "Starting Gource primary with title: ${GOURCE_TITLE}"
G1_CMD=\
    ( \
        ${GOURCE_EXEC} \
        --${GOURCE_RES} \
        "${GOURCE_PRIMARY_ARGS[@]}" \
        --stop-at-end \
        /visualization/development.log \
        -r ${FPS} \
        -o \
    )

[ "${TEST}" = "1" ] && printf "%s " "${G1_CMD[@]}" >> /visualization/cmd_test_data.txt
[ "${NORUN}" != "1" ] && "${G1_CMD[@]}" - >/visualization/tmp/gource.pipe &

# Start Gource for the overlay elements.
log_notice "Starting Gource secondary for overlay components"
G2_CMD=\
    ( \
        ${GOURCE_EXEC} \
        --${OVERLAY_RES} \
        "${GOURCE_SECONDARY_ARGS[@]}" \
        --transparent \
        --background-colour 202021 \
        --stop-at-end \
        /visualization/development.log \
        -r ${FPS} \
        -o \
    )

[ "${TEST}" = "1" ] && printf "%s " "${G2_CMD[@]}" >> /visualization/cmd_test_data.txt
[ "${NORUN}" != "1" ] && "${G2_CMD[@]}" - >/visualization/tmp/overlay.pipe &


# Start ffmpeg to merge the two video outputs.
log_notice "Combining videos pipes and rendering..."
mkdir -p /visualization/video
# [0:v]: gource, [1:v]: overlay, [2:v]: logo
F_CMD=\
    ( \
        ffmpeg -y -r ${FPS} -f image2pipe -probesize 100M -i /visualization/tmp/gource.pipe \
        -y -r ${FPS} -f image2pipe -probesize 100M -i /visualization/tmp/overlay.pipe \
        ${LOGO} \
        -filter_complex "[0:v]pad=${GOURCE_PAD}${INVERT_FILTER}[center];\
                    [1:v]scale=${OUTPUT_RES}[key_scale];\
                    [1:v]scale=${OUTPUT_RES}[date_scale];\
                    [key_scale]crop=${KEY_CROP},pad=${KEY_PAD}[key];\
                    [date_scale]crop=${DATE_CROP},pad=${DATE_PAD}[date];\
                    [key][center]hstack[with_key];\
                    [date][with_key]vstack[default]\
        ${LOGO_FILTER_GRAPH}${LIVE_PREVIEW_SPLITTER}" -map ${PRIMARY_MAP_LABEL} \
        -vcodec libx265 -pix_fmt yuv420p -crf ${H265_CRF} -preset ${H265_PRESET} /visualization/video/output.mp4 \
        ${LIVE_PREVIEW_ARGS} \
    )

[ "${TEST}" = "1" ] && printf "%s " "${F_CMD[@]}" >> /visualization/cmd_test_data.txt
[ "${NORUN}" != "1" ] && "${F_CMD[@]}"
[ "${TEST}" = "1" ] && log_success "Test Files Written!" && rm -rf /visualization/tmp && exit 0

log_success "FFmpeg video render completed!"
# Remove our temporary files.
log_notice "Removing temporary files."
rm -rf /visualization/tmp

# Update html and link new video.
filesize="$(du -sh /visualization/video/output.mp4 | cut -f 1)"
printf "$(cat /visualization/html/completed.html)" $filesize >/visualization/html/index.html
ln -sf /visualization/video/output.mp4 /visualization/html/output.mp4
