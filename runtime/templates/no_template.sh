#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: MIT

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. "${DIR}/../common/common.bash"

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

# Generate ffmpeg flags
LOGO_FFMPEG_LABEL="[1:v]" && gen_ffmpeg_flags

# Create our temp directory
mkdir -p /visualization/tmp

# Create our named pipes.
mkfifo /visualization/tmp/gource.pipe

# Generate our Gource args
gen_gource_args


log_notice "Starting Gource primary with title: ${GOURCE_TITLE}"
${GOURCE_EXEC} \
    --${GOURCE_RES} \
    "${GOURCE_ARG_ARRAY[@]}" \
    --stop-at-end \
    /visualization/development.log \
    -r ${FPS} \
    -o - >/visualization/tmp/gource.pipe &

# Start ffmpeg
log_notice "Rendering video pipe.."
mkdir -p /visualization/video
# [0:v]: gource, [1:v]: logo
ffmpeg -y -r ${FPS} -f image2pipe -probesize 100M -i ./tmp/gource.pipe \
    ${LOGO} \
    -filter_complex "[0:v]select${INVERT_FILTER}[default]${LOGO_FILTER_GRAPH}${LIVE_PREVIEW_SPLITTER}" \
    -map ${PRIMARY_MAP_LABEL} -vcodec libx265 -pix_fmt yuv420p -crf ${H265_CRF} -preset ${H265_PRESET} \
    /visualization/video/output.mp4 ${LIVE_PREVIEW_ARGS}

log_success "FFmpeg video render completed!"
# Remove our temporary files.
echo "Removing temporary files."
rm -rf /visualization/tmp

# Update html and link new video.
filesize="$(du -sh /visualization/video/output.mp4 | cut -f 1)"
printf "$(cat /visualization/html/completed.html)" $filesize >/visualization/html/index.html
ln -sf /visualization/video/output.mp4 /visualization/html/output.mp4
