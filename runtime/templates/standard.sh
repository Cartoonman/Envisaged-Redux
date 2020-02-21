#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
# Copyright (c) 2019 Utensils Union
#
# SPDX-License-Identifier: Apache-2.0 AND MIT

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH
source "${CUR_DIR_PATH}/../common/common_templates.bash"

exit_handler()
{
    # Exit Gource if still alive.
    stop_process "${_G_PID}"
    stop_process "${_F_PID}"
    log_debug "Render process returning with code ${EXIT_CODE}"
    exit "${EXIT_CODE}"
}
readonly -f exit_handler

# Predefined resolutions and settings.
case ${RENDER_VIDEO_RESOLUTION} in
    2160p)
        gource_res="3840x2160"
        log_info "Using 2160p settings. Output will be 3840x2160 at ${RENDER_FPS}fps."
        ;;
    1440p)
        gource_res="2560x1440"
        log_info "Using 1440p settings. Output will be 2560x1440 at ${RENDER_FPS}fps."
        ;;
    1080p)
        gource_res="1920x1080"
        log_info "Using 1080p settings. Output will be 1920x1080 at ${RENDER_FPS}fps."
        ;;
    720p)
        gource_res="1280x720"
        log_info "Using 720p settings. Output will be 1280x720 at ${RENDER_FPS}fps."
        ;;
    480p)
        gource_res="854x480"
        log_info "Using 720p settings. Output will be 1280x720 at ${RENDER_FPS}fps."
        ;;
    *)
        log_error "${RENDER_VIDEO_RESOLUTION} is not a valid/supported video resolution."
        EXIT_CODE=1
        exit_handler
        ;;
esac

# Generate ffmpeg flags
logo_ffmpeg_label="[1:v]" && gen_ffmpeg_flags
(( $? != 0 )) && EXIT_CODE=1 && exit_handler

# Create our named pipes.
mkfifo "${ER_ROOT_DIRECTORY}"/tmp/gource.pipe

# Generate our Gource args
gen_gource_args

declare -ig _G_PID _F_PID

trap 'stop_process "${_G_PID}";\
      stop_process "${_F_PID}";\
      log_error "Error occured during render stage.";\
      exit 1;' SIGTRAP

trap 'stop_process "${_G_PID}";\
      stop_process "${_F_PID}";\
      log_notice "Received SIGINT";\
      exit 1;' SIGINT


log_notice "Starting Gource primary with title [${GOURCE_TITLE}]"
g_cmd_tmp=( \
        "${RT_GOURCE_EXEC}" \
        --"${gource_res}" \
        "${gource_arg_array[@]}" \
        --stop-at-end \
        --disable-input \
        "${ER_ROOT_DIRECTORY}"/tmp/gource.log \
        -r "${RENDER_FPS}" \
        -o \
    )
# Sanitize array
declare -a g_cmd=()
for var in "${g_cmd_tmp[@]}"; do
    [ -n "${var}" ] && g_cmd+=("${var}")
done
unset g_cmd_tmp

(( RT_TEST == 1 )) && printf "%s " "${g_cmd[@]}" >> "${ER_ROOT_DIRECTORY}"/save/cmd_test_data.txt
if (( RT_NO_RUN != 1 )); then
    (
        "${g_cmd[@]}" - >"${ER_ROOT_DIRECTORY}"/tmp/gource.pipe
        g_exit_code=$?
        if (( g_exit_code != 0 )); then
            log_error "Gource encountered an error."
            kill -s SIGTRAP $$
        fi
    ) &
    _G_PID=$!
fi

# Start ffmpeg
log_notice "Rendering video pipe.."
mkdir -p "${ER_ROOT_DIRECTORY}"/video
# [0:v]: gource, [1:v]: logo
f_cmd_tmp=( \
        ffmpeg -y -f image2pipe -probesize 100M -thread_queue_size 512 -framerate "${RENDER_FPS}" -i ./tmp/gource.pipe \
        "${logo_input[@]}" \
        -filter_complex "[0:v]select${invert_filter}[default]${logo_filter_graph}${live_preview_splitter}" \
        -map "${primary_map_label}" -vcodec libx265 -pix_fmt yuv420p -crf "${RENDER_H265_CRF}" -preset "${RENDER_H265_PRESET}" \
        "${ER_ROOT_DIRECTORY}"/video/output.mp4 "${live_preview_args[@]}" \
    )
# Sanitize array
declare -a f_cmd=()
for var in "${f_cmd_tmp[@]}"; do
    [ -n "${var}" ] && f_cmd+=("${var}")
done
unset f_cmd_tmp

if (( RT_TEST == 1 )); then
    tmp_output="$(printf "%s " "${f_cmd[@]}")"
    printf "%s" "${tmp_output%?}" >> "${ER_ROOT_DIRECTORY}"/save/cmd_test_data.txt
fi
if (( RT_NO_RUN != 1 )); then
    (
        "${f_cmd[@]}"
        f_exit_code=$?
        if (( f_exit_code != 0 )); then
            log_error "FFmpeg encountered an error"
            kill -s SIGTRAP $$
        fi
    ) &
    _F_PID=$!
    wait "${_F_PID}" "${_G_PID}"
fi

if (( EXIT_CODE != 0 )); then
    log_error "FFmpeg video render failed!"
else
    log_success "FFmpeg video render completed!"

    # Update html and link new video.
    if (( RT_TEST != 1 )) && (( RT_LOCAL_OUTPUT != 1 )); then
        filesize="$(du -sh "${ER_ROOT_DIRECTORY}"/video/output.mp4 | cut -f 1)"
        printf "$(cat "${ER_ROOT_DIRECTORY}"/html/completed.html)" $filesize >"${ER_ROOT_DIRECTORY}"/html/index.html
        ln -sf "${ER_ROOT_DIRECTORY}"/video/output.mp4 "${ER_ROOT_DIRECTORY}"/html/output.mp4
    fi
fi
exit_handler