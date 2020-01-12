#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: Apache-2.0 AND MIT

declare -r CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${CUR_DIR_PATH}/../common/common_templates.bash"

# Predefined resolutions and settings.
case ${VIDEO_RESOLUTION} in
    2160p)
        gource_res="3840x2160"
        log_info "Using 2160p settings. Output will be 3840x2160 at ${FPS}fps."
        ;;
    1440p)
        gource_res="2560x1440"
        log_info "Using 1440p settings. Output will be 2560x1440 at ${FPS}fps."
        ;;
    1080p)
        gource_res="1920x1080"
        log_info "Using 1080p settings. Output will be 1920x1080 at ${FPS}fps."
        ;;
    720p)
        gource_res="1280x720"
        log_info "Using 720p settings. Output will be 1280x720 at ${FPS}fps."
        ;;
    480p)
        gource_res="854x480"
        log_info "Using 720p settings. Output will be 1280x720 at ${FPS}fps."
        ;;
    *)
        log_error "${VIDEO_RESOLUTION} is not a valid/supported video resolution."
        exit 1
        ;;
esac

# Generate ffmpeg flags
logo_ffmpeg_label="[1:v]" && gen_ffmpeg_flags

# Create our temp directory
mkdir -p /visualization/tmp

# Create our named pipes.
mkfifo /visualization/tmp/gource.pipe

# Generate our Gource args
gen_gource_args


log_notice "Starting Gource primary with title: ${GOURCE_TITLE}"
g_cmd=( \
        ${GOURCE_EXEC} \
        --${gource_res} \
        "${gource_arg_array[@]}" \
        --stop-at-end \
        /visualization/development.log \
        -r ${FPS} \
        -o \
    )

[ "${TEST}" = "1" ] && printf "%s " "${g_cmd[@]}" >> /visualization/cmd_test_data.txt
[ "${NORUN}" != "1" ] && "${g_cmd[@]}" - >/visualization/tmp/gource.pipe &

# Start ffmpeg
log_notice "Rendering video pipe.."
mkdir -p /visualization/video
# [0:v]: gource, [1:v]: logo
f_cmd=( \
        ffmpeg -y -r ${FPS} -f image2pipe -probesize 100M -i ./tmp/gource.pipe \
        ${LOGO} \
        -filter_complex "[0:v]select${invert_filter}[default]${logo_filter_graph}${live_preview_splitter}" \
        -map ${primary_map_label} -vcodec libx265 -pix_fmt yuv420p -crf ${H265_CRF} -preset ${H265_PRESET} \
        /visualization/video/output.mp4 ${live_preview_args} \
    )

[ "${TEST}" = "1" ] && printf "%s " "${f_cmd[@]}" >> /visualization/cmd_test_data.txt
[ "${NORUN}" != "1" ] && "${f_cmd[@]}"
[ "${TEST}" = "1" ] && log_success "Test Files Written!" && rm -rf /visualization/tmp && exit 0

log_success "FFmpeg video render completed!"
# Remove our temporary files.
echo "Removing temporary files."
rm -rf /visualization/tmp

# Update html and link new video.
filesize="$(du -sh /visualization/video/output.mp4 | cut -f 1)"
printf "$(cat /visualization/html/completed.html)" $filesize >/visualization/html/index.html
ln -sf /visualization/video/output.mp4 /visualization/html/output.mp4
