#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: Apache-2.0 AND MIT

declare -r CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${CUR_DIR_PATH}/../common/common_templates.bash"

# Predefined resolutions and settings.
if [[ "${VIDEO_RESOLUTION}" == "2160p" ]]; then
    gource_res="3500x1940"
    overlay_res="1920x1080"
    gource_pad="3520:1960:3520:1960:#313133"
    key_crop="320:1860:0:0"
    key_pad="320:1960:0:0:#202021"
    date_crop="3520:200:640:0"
    date_pad="3840:200:320:200:#202021"
    output_res="3840:2160"
    log_info "Using 2160p settings. Output will be 3840x2160 at ${FPS}fps."
elif [[ "${VIDEO_RESOLUTION}" == "1440p" ]]; then
    gource_res="2333x1293"
    overlay_res="1920x1080"
    gource_pad="2346:1306:2346:1306:#313133"
    key_crop="214:1240:0:0"
    key_pad="214:1306:0:0:#202021"
    date_crop="2346:134:426:0"
    date_pad="2560:134:214:134:#202021"
    output_res="2560:1440"
    log_info "Using 1440p settings. Output will be 2560x1440 at ${FPS}fps."
elif [[ "${VIDEO_RESOLUTION}" == "1080p" ]]; then
    gource_res="1750x970"
    overlay_res="1920x1080"
    gource_pad="1760:980:1760:980:#313133"
    key_crop="160:930:0:0"
    key_pad="160:980:0:0:#202021"
    date_crop="1760:100:320:0"
    date_pad="1920:100:160:100:#202021"
    output_res="1920:1080"
    log_info "Using 1080p settings. Output will be 1920x1080 at ${FPS}fps."
elif [[ "${VIDEO_RESOLUTION}" == "720p" ]]; then
    gource_res="1116x646"
    overlay_res="1280x720"
    gource_pad="1128:653:1128:653:#313133"
    key_crop="152:590:0:0"
    key_pad="152:653:0:0:#202021"
    date_crop="1128:67:152:0"
    date_pad="1280:67:152:67:#202021"
    output_res="1280:720"
    log_info "Using 720p settings. Output will be 1280x720 at ${FPS}fps."
elif [[ "${VIDEO_RESOLUTION}" == "480p" ]]; then
    gource_res="700x410"
    overlay_res="854x480"
    gource_pad="708:420:708:420:#313133"
    key_crop="146:390:0:0"
    key_pad="146:420:0:0:#202021"
    date_crop="708:60:146:0"
    date_pad="854:60:146:60:#202021"
    output_res="854:480"
    log_info "Using 480p settings. Output will be 854x480 at ${FPS}fps."
else
    log_error "${VIDEO_RESOLUTION} is not a valid/supported video resolution."
    exit 1
fi

# Generate ffmpeg flags
logo_ffmpeg_label="[2:v]" && gen_ffmpeg_flags

# Create our temp directory
mkdir -p /visualization/tmp

# Create our named pipes.
mkfifo /visualization/tmp/gource.pipe
mkfifo /visualization/tmp/overlay.pipe


# Save backup of Env Vars to be overridden
gource_font_size_backup = "${GOURCE_FONT_SIZE}"
gource_font_color_backup = "${GOURCE_FONT_COLOR}"
gource_hide_items_backup = "${GOURCE_HIDE_ITEMS}"
gource_show_key_backup = "${GOURCE_SHOW_KEY}"
gource_background_color_backup = "${GOURCE_BACKGROUND_COLOR}"

# Generate args for Primary Gource
GOURCE_FONT_SIZE="${GOURCE_BORDER_TITLE_FONT_SIZE}"
GOURCE_FONT_COLOR="${GOURCE_BORDER_TITLE_TEXT_COLOR}"
GOURCE_HIDE_ITEMS="date,mouse,${GOURCE_HIDE_ITEMS}"
GOURCE_SHOW_KEY=0

gen_gource_args
gource_primary_args=("${gource_arg_array[@]}")

# Generate args for Secondary Gource
GOURCE_FONT_SIZE="${GOURCE_BORDER_TITLE_FONT_SIZE}"
GOURCE_FONT_COLOR="${GOURCE_BORDER_DATE_FONT_COLOR}"
GOURCE_HIDE_ITEMS="bloom,dirnames,files,filenames,mouse,root,tree,users,usernames"
GOURCE_SHOW_KEY=1
GOURCE_BACKGROUND_COLOR=""

gen_gource_args
gource_secondary_args=("${gource_arg_array[@]}")


# Restore Env Vars
GOURCE_FONT_SIZE = "${gource_font_size_backup}"
GOURCE_FONT_COLOR = "${gource_font_color_backup}"
GOURCE_HIDE_ITEMS = "${gource_hide_items_backup}"
GOURCE_SHOW_KEY = "${gource_show_key_backup}"
GOURCE_BACKGROUND_COLOR = "${gource_background_color_backup}"

unset gource_font_size_backup
unset gource_font_color_backup
unset gource_hide_items_backup
unset gource_show_key_backup
unset gource_background_color_backup


# Start Gource for visualization.
log_notice "Starting Gource primary with title: ${GOURCE_TITLE}"
g1_cmd=( \
        ${GOURCE_EXEC} \
        --${gource_res} \
        "${gource_primary_args[@]}" \
        --stop-at-end \
        /visualization/development.log \
        -r ${FPS} \
        -o \
    )

[ "${TEST}" = "1" ] && printf "%s " "${g1_cmd[@]}" >> /visualization/cmd_test_data.txt
[ "${NORUN}" != "1" ] && "${g1_cmd[@]}" - >/visualization/tmp/gource.pipe &

# Start Gource for the overlay elements.
log_notice "Starting Gource secondary for overlay components"
g2_cmd=( \
        ${GOURCE_EXEC} \
        --${overlay_res} \
        "${gource_secondary_args[@]}" \
        --transparent \
        --background-colour 202021 \
        --stop-at-end \
        /visualization/development.log \
        -r ${FPS} \
        -o \
    )

[ "${TEST}" = "1" ] && printf "%s " "${g2_cmd[@]}" >> /visualization/cmd_test_data.txt
[ "${NORUN}" != "1" ] && "${g2_cmd[@]}" - >/visualization/tmp/overlay.pipe &


# Start ffmpeg to merge the two video outputs.
log_notice "Combining videos pipes and rendering..."
mkdir -p /visualization/video
# [0:v]: gource, [1:v]: overlay, [2:v]: logo
f_cmd=( \
        ffmpeg -y -r ${FPS} -f image2pipe -probesize 100M -i /visualization/tmp/gource.pipe \
        -y -r ${FPS} -f image2pipe -probesize 100M -i /visualization/tmp/overlay.pipe \
        ${LOGO} \
        -filter_complex "[0:v]pad=${gource_pad}${invert_filter}[center];\
                    [1:v]scale=${output_res}[key_scale];\
                    [1:v]scale=${output_res}[date_scale];\
                    [key_scale]crop=${key_crop},pad=${key_pad}[key];\
                    [date_scale]crop=${date_crop},pad=${date_pad}[date];\
                    [key][center]hstack[with_key];\
                    [date][with_key]vstack[default]\
        ${logo_filter_graph}${live_preview_splitter}" -map ${primary_map_label} \
        -vcodec libx265 -pix_fmt yuv420p -crf ${H265_CRF} -preset ${H265_PRESET} /visualization/video/output.mp4 \
        ${live_preview_args} \
    )

[ "${TEST}" = "1" ] && printf "%s " "${f_cmd[@]}" >> /visualization/cmd_test_data.txt
[ "${NORUN}" != "1" ] && "${f_cmd[@]}"
[ "${TEST}" = "1" ] && log_success "Test Files Written!" && rm -rf /visualization/tmp && exit 0

log_success "FFmpeg video render completed!"
# Remove our temporary files.
log_notice "Removing temporary files."
rm -rf /visualization/tmp

# Update html and link new video.
filesize="$(du -sh /visualization/video/output.mp4 | cut -f 1)"
printf "$(cat /visualization/html/completed.html)" $filesize >/visualization/html/index.html
ln -sf /visualization/video/output.mp4 /visualization/html/output.mp4
