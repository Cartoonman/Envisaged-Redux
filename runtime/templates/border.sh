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
    # Exit Processes if still alive.
    stop_process ${_G1_PID}
    stop_process ${_G2_PID}
    stop_process ${_F_PID}
    log_debug "Render process returning with code [${EXIT_CODE}]."
    exit ${EXIT_CODE}
}
readonly -f exit_handler

# Predefined resolutions and settings.
case ${RENDER_VIDEO_RESOLUTION} in
    2160p)
        gource_res="3500x1940"
        overlay_res="1920x1080"
        gource_pad="3520:1960:3520:1960:#313133"
        key_crop="320:1860:0:0"
        key_pad="320:1960:0:0:#202021"
        date_crop="3520:200:640:0"
        date_pad="3840:200:320:200:#202021"
        output_res="3840:2160"
        log_info "Using 2160p settings. Output will be 3840x2160 at ${RENDER_FPS}fps."
        ;;
    1440p)
        gource_res="2333x1293"
        overlay_res="1920x1080"
        gource_pad="2346:1306:2346:1306:#313133"
        key_crop="214:1240:0:0"
        key_pad="214:1306:0:0:#202021"
        date_crop="2346:134:426:0"
        date_pad="2560:134:214:134:#202021"
        output_res="2560:1440"
        log_info "Using 1440p settings. Output will be 2560x1440 at ${RENDER_FPS}fps."
        ;;
    1080p)
        gource_res="1750x970"
        overlay_res="1920x1080"
        gource_pad="1760:980:1760:980:#313133"
        key_crop="160:930:0:0"
        key_pad="160:980:0:0:#202021"
        date_crop="1760:100:320:0"
        date_pad="1920:100:160:100:#202021"
        output_res="1920:1080"
        log_info "Using 1080p settings. Output will be 1920x1080 at ${RENDER_FPS}fps."
        ;;
    720p)
        gource_res="1116x646"
        overlay_res="1280x720"
        gource_pad="1128:653:1128:653:#313133"
        key_crop="152:590:0:0"
        key_pad="152:653:0:0:#202021"
        date_crop="1128:67:152:0"
        date_pad="1280:67:152:67:#202021"
        output_res="1280:720"
        log_info "Using 720p settings. Output will be 1280x720 at ${RENDER_FPS}fps."
        ;;
    480p)
        gource_res="700x410"
        overlay_res="854x480"
        gource_pad="708:420:708:420:#313133"
        key_crop="146:390:0:0"
        key_pad="146:420:0:0:#202021"
        date_crop="708:60:146:0"
        date_pad="854:60:146:60:#202021"
        output_res="854:480"
        log_info "Using 480p settings. Output will be 854x480 at ${RENDER_FPS}fps."
        ;;
    *)
        log_error "${RENDER_VIDEO_RESOLUTION} is not a valid/supported video resolution."
        EXIT_CODE=1
        exit_handler
        ;;
esac


# Generate ffmpeg flags
logo_ffmpeg_label="[2:v]" && gen_ffmpeg_flags
(( $? != 0 )) && EXIT_CODE=1 && exit_handler

# Create our named pipes.
mkfifo "${ER_ROOT_DIRECTORY}"/tmp/gource.pipe
mkfifo "${ER_ROOT_DIRECTORY}"/tmp/overlay.pipe


# Save backup of Env Vars to be overridden
gource_font_size_backup="${GOURCE_FONT_SIZE}"
gource_font_color_backup="${GOURCE_FONT_COLOR}"
gource_hide_items_backup="${GOURCE_HIDE_ITEMS}"
gource_show_key_backup="${GOURCE_SHOW_KEY}"
gource_background_color_backup="${GOURCE_BACKGROUND_COLOR}"
gource_follow_user_backup="${GOURCE_FOLLOW_USER}" # Patch because Gource does not obey --hide for selected users. 

# Generate args for Primary Gource
GOURCE_FONT_SIZE="${GOURCE_BORDER_TITLE_SIZE}"
GOURCE_FONT_COLOR="${GOURCE_BORDER_TITLE_COLOR}"
GOURCE_HIDE_ITEMS="date,mouse,${GOURCE_HIDE_ITEMS}"
GOURCE_SHOW_KEY=0

gen_gource_args
gource_primary_args=("${gource_arg_array[@]}")

# Generate args for Secondary Gource
GOURCE_FONT_SIZE="${GOURCE_BORDER_DATE_SIZE}"
GOURCE_FONT_COLOR="${GOURCE_BORDER_DATE_COLOR}"
GOURCE_HIDE_ITEMS="bloom,dirnames,files,filenames,mouse,root,tree,users,usernames"
GOURCE_SHOW_KEY=1
GOURCE_BACKGROUND_COLOR=""
GOURCE_FOLLOW_USER=""
(( RT_BACKGROUND_IMAGE == 1 )) && RT_BACKGROUND_IMAGE=0

gen_gource_args
gource_secondary_args=("${gource_arg_array[@]}")


# Restore Env Vars
GOURCE_FONT_SIZE="${gource_font_size_backup}"
GOURCE_FONT_COLOR="${gource_font_color_backup}"
GOURCE_HIDE_ITEMS="${gource_hide_items_backup}"
GOURCE_SHOW_KEY="${gource_show_key_backup}"
GOURCE_BACKGROUND_COLOR="${gource_background_color_backup}"
GOURCE_FOLLOW_USER="${gource_follow_user_backup}"


declare -ig _G1_PID _G2_PID _F_PID

trap 'stop_process ${_G1_PID};\
      stop_process ${_G2_PID};\
      stop_process ${_F_PID};\
      log_error "Error occured during render stage.";\
      exit 1;' SIGTRAP

trap 'stop_process ${_G1_PID};\
      stop_process ${_G2_PID};\
      stop_process ${_F_PID};\
      log_notice "Received SIGINT.";\
      exit 130;' SIGINT

# Start Gource for visualization.
log_notice "Starting Gource primary with title [${GOURCE_TITLE}]."
g1_cmd_tmp=( \
        "${RT_GOURCE_EXEC}" \
        --"${gource_res}" \
        "${gource_primary_args[@]}" \
        --stop-at-end \
        --disable-input \
        "${ER_ROOT_DIRECTORY}"/tmp/gource.log \
        -r "${RENDER_FPS}" \
        -o \
    )
# Sanitize array
declare -a g1_cmd=()
for var in "${g1_cmd_tmp[@]}"; do
    [ -n "${var}" ] && g1_cmd+=("${var}")
done
unset g1_cmd_tmp

(( RT_TEST == 1 )) && printf "%s " "${g1_cmd[@]}" >> "${ER_ROOT_DIRECTORY}"/save/cmd_test_data.txt
if (( RT_NO_RUN != 1 )); then
    (
        "${g1_cmd[@]}" - >"${ER_ROOT_DIRECTORY}"/tmp/gource.pipe
        g1_exit_code=$?
        if (( g1_exit_code != 0 )); then
            log_error "Gource encountered an error. Exit code: [${g1_exit_code}]."
            kill -s SIGTRAP $$
        fi
    ) &
    _G1_PID=$!
fi

# Start Gource for the overlay elements.
log_notice "Starting Gource secondary for overlay components."
g2_cmd_tmp=( \
        "${RT_GOURCE_EXEC}" \
        --"${overlay_res}" \
        "${gource_secondary_args[@]}" \
        --transparent \
        --background-colour 202021 \
        --stop-at-end \
        "${ER_ROOT_DIRECTORY}"/tmp/gource.log \
        -r "${RENDER_FPS}" \
        -o \
    )
# Sanitize array
declare -a g2_cmd=()
for var in "${g2_cmd_tmp[@]}"; do
    [ -n "${var}" ] && g2_cmd+=("${var}")
done
unset g2_cmd_tmp

(( RT_TEST == 1 )) && printf "%s " "${g2_cmd[@]}" >> "${ER_ROOT_DIRECTORY}"/save/cmd_test_data.txt
if (( RT_NO_RUN != 1 )); then
    (
        "${g2_cmd[@]}" - >"${ER_ROOT_DIRECTORY}"/tmp/overlay.pipe
        g2_exit_code=$?
        if (( g2_exit_code != 0 )); then
            log_error "Gource overlay encountered an error. Exit code: [${g2_exit_code}]."
            kill -s SIGTRAP $$
        fi
    ) &
    _G2_PID=$!
fi

# Start ffmpeg to merge the two video outputs.
log_notice "Combining videos pipes and rendering..."
mkdir -p "${ER_ROOT_DIRECTORY}"/video
# [0:v]: gource, [1:v]: overlay, [2:v]: logo
f_filter_complex="$( \
    printf "%s" \
        "[0:v]pad=${gource_pad}${invert_filter}[center];" \
        "[1:v]scale=${output_res}[key_scale];" \
        "[1:v]scale=${output_res}[date_scale];" \
        "[key_scale]crop=${key_crop},pad=${key_pad}[key];" \
        "[date_scale]crop=${date_crop},pad=${date_pad}[date];" \
        "[key][center]hstack[with_key];" \
        "[date][with_key]vstack[default]${logo_filter_graph}${live_preview_splitter}" \
)"
# -hide_banner -nostats <<- maintain forever. -progress pipe:${fd_out} <<- Enable progress --> adjust this verbocity. -loglevel warning/info
f_cmd_tmp=( \
        ffmpeg -hide_banner -nostats "${ffmpeg_progress[@]}" -loglevel "${ffmpeg_verbosity}" -y \
        -f image2pipe -probesize 100M -thread_queue_size 512 -framerate "${RENDER_FPS}" -i "${ER_ROOT_DIRECTORY}"/tmp/gource.pipe \
        -f image2pipe -probesize 100M -thread_queue_size 512 -framerate "${RENDER_FPS}" -i "${ER_ROOT_DIRECTORY}"/tmp/overlay.pipe \
        "${logo_input[@]}" \
        -filter_complex "${f_filter_complex}" -map "${primary_map_label}" \
        -vcodec "${ffmpeg_codec}" -pix_fmt yuv420p -crf "${RENDER_H265_CRF}" "${ffmpeg_profile[@]}" "${ffmpeg_level[@]}" \
        -preset "${RENDER_H265_PRESET}" "${ER_ROOT_DIRECTORY}"/video/output.mp4 \
        "${live_preview_args[@]}" \
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
            log_error "FFmpeg encountered an error. Exit code: [${f_exit_code}]."
            kill -s SIGTRAP $$
        fi
    ) &
    _F_PID=$!
    # Handle live progress if required.
    if [ "${RENDER_NO_PROGRESS}" != "1" ]; then
        while [ -e "/proc/${_F_PID}" ] && [ -e "/proc/${_G1_PID}" ] && [ -e "/proc/${_G2_PID}" ]; do
            while read -r -u ${fd_in} line; do
                ffmpeg_progress_display "${line}"
            done
            sleep 0.25
        done
        # Close file descriptors
        exec {fd_out}>&-
        exec {fd_in}<&-
        printf "\n"
    fi
    wait ${_F_PID} ${_G1_PID} ${_G2_PID}
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