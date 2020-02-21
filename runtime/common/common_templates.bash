#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

inc_dir_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${inc_dir_path}/common.bash"
unset inc_dir_path

# Assign defaults if not set
: "${RENDER_H265_PRESET:=medium}"
: "${RENDER_H265_CRF:=21}"
: "${RENDER_VIDEO_RESOLUTION:=1080p}"
: "${RENDER_FPS:=30}"

# gen_gource_args
# Generates an indexed array of gource args to pass to gource.
#
#
# Consumes:
#   Gource Global Environment Variables, user-defined.
# Arguments:
#   none
# Outputs:
#   gource_arg_array - indexed array with gource args to 
#   forward to Gource.
gen_gource_args()
{
    declare -ga gource_arg_array=()

    [ -n "${GOURCE_TITLE}" ]                    && gource_arg_array+=("--title" "${GOURCE_TITLE}")
    [ -n "${GOURCE_CAMERA_MODE}" ]              && gource_arg_array+=("--camera-mode" "${GOURCE_CAMERA_MODE}")
    [ -n "${GOURCE_START_DATE}" ]               && gource_arg_array+=("--start-date" "${GOURCE_START_DATE}")
    [ -n "${GOURCE_STOP_DATE}" ]                && gource_arg_array+=("--stop-date" "${GOURCE_STOP_DATE}")
    [ -n "${GOURCE_START_POSITION}" ]           && gource_arg_array+=("--start-position" "${GOURCE_START_POSITION}")
    [ -n "${GOURCE_STOP_POSITION}" ]            && gource_arg_array+=("--stop-position" "${GOURCE_STOP_POSITION}")
    [ -n "${GOURCE_STOP_AT_TIME}" ]             && gource_arg_array+=("--stop-at-time" "${GOURCE_STOP_AT_TIME}")
    [ -n "${GOURCE_SECONDS_PER_DAY}" ]          && gource_arg_array+=("--seconds-per-day" "${GOURCE_SECONDS_PER_DAY}")
    [ -n "${GOURCE_AUTO_SKIP_SECONDS}" ]        && gource_arg_array+=("--auto-skip-seconds" "${GOURCE_AUTO_SKIP_SECONDS}")
    [ -n "${GOURCE_TIME_SCALE}" ]               && gource_arg_array+=("--time-scale" "${GOURCE_TIME_SCALE}")
    [ -n "${GOURCE_USER_SCALE}" ]               && gource_arg_array+=("--user-scale" "${GOURCE_USER_SCALE}")
    [ -n "${GOURCE_MAX_USER_SPEED}" ]           && gource_arg_array+=("--max-user-speed" "${GOURCE_MAX_USER_SPEED}")
    [ -n "${GOURCE_HIDE_ITEMS}" ]               && gource_arg_array+=("--hide" "${GOURCE_HIDE_ITEMS}")
    [ -n "${GOURCE_FILE_IDLE_TIME}" ]           && gource_arg_array+=("--file-idle-time" "${GOURCE_FILE_IDLE_TIME}")
    [ -n "${GOURCE_MAX_FILES}" ]                && gource_arg_array+=("--max-files" "${GOURCE_MAX_FILES}")
    [ -n "${GOURCE_MAX_FILE_LAG}" ]             && gource_arg_array+=("--max-file-lag" "${GOURCE_MAX_FILE_LAG}")
    [ -n "${GOURCE_FILENAME_TIME}" ]            && gource_arg_array+=("--filename-time" "${GOURCE_FILENAME_TIME}")
    [ -n "${GOURCE_FONT_SIZE}" ]                && gource_arg_array+=("--font-size" "${GOURCE_FONT_SIZE}")
    [ -n "${GOURCE_FONT_COLOR}" ]               && gource_arg_array+=("--font-colour" "${GOURCE_FONT_COLOR}")
    [ -n "${GOURCE_BACKGROUND_COLOR}" ]         && gource_arg_array+=("--background-colour" "${GOURCE_BACKGROUND_COLOR}")
    [ -n "${GOURCE_DATE_FORMAT}" ]              && gource_arg_array+=("--date-format" "${GOURCE_DATE_FORMAT}")
    [ -n "${GOURCE_DIR_NAME_DEPTH}" ]           && gource_arg_array+=("--dir-name-depth" "${GOURCE_DIR_NAME_DEPTH}")
    [ -n "${GOURCE_BLOOM_MULTIPLIER}" ]         && gource_arg_array+=("--bloom-multiplier" "${GOURCE_BLOOM_MULTIPLIER}")
    [ -n "${GOURCE_BLOOM_INTENSITY}" ]          && gource_arg_array+=("--bloom-intensity" "${GOURCE_BLOOM_INTENSITY}")
    [ -n "${GOURCE_PADDING}" ]                  && gource_arg_array+=("--padding" "${GOURCE_PADDING}")
    [ -n "${GOURCE_ELASTICITY}" ]               && gource_arg_array+=("--elasticity" "${GOURCE_ELASTICITY}")
    [ -n "${GOURCE_FOLLOW_USER}" ]              && gource_arg_array+=("--follow-user" "${GOURCE_FOLLOW_USER}")
    [ -n "${GOURCE_HIGHLIGHT_COLOR}" ]          && gource_arg_array+=("--highlight-colour" "${GOURCE_HIGHLIGHT_COLOR}")
    [ -n "${GOURCE_SELECTION_COLOR}" ]          && gource_arg_array+=("--selection-colour" "${GOURCE_SELECTION_COLOR}")
    [ -n "${GOURCE_FILENAME_COLOR}" ]           && gource_arg_array+=("--filename-colour" "${GOURCE_FILENAME_COLOR}")
    [ -n "${GOURCE_DIR_COLOR}" ]                && gource_arg_array+=("--dir-colour" "${GOURCE_DIR_COLOR}")
    [ -n "${GOURCE_USER_FRICTION}" ]            && gource_arg_array+=("--user-friction" "${GOURCE_USER_FRICTION}")
    [ "${GOURCE_HIGHLIGHT_USERS}" = "1" ]       && gource_arg_array+=("--highlight-users")
    [ "${GOURCE_MULTI_SAMPLING}" = "1" ]        && gource_arg_array+=("--multi-sampling")
    [ "${GOURCE_SHOW_KEY}" = "1" ]              && gource_arg_array+=("--key")
    [ "${GOURCE_REALTIME}" = "1" ]              && gource_arg_array+=("--realtime")
    [ "${GOURCE_HIGHLIGHT_DIRS}" = "1" ]        && gource_arg_array+=("--highlight-dirs")
    [ "${GOURCE_FILE_EXTENSIONS}" = "1" ]       && gource_arg_array+=("--file-extensions")
    [ "${GOURCE_DISABLE_AUTO_ROTATE}" = "1" ]   && gource_arg_array+=("--disable-auto-rotate")
    [ "${GOURCE_COLOR_IMAGES}" = "1" ]          && gource_arg_array+=("--colour-images")
    

    # Captions
    (( RT_CAPTIONS == 1 ))                      && gource_arg_array+=("--caption-file" "${ER_ROOT_DIRECTORY}/resources/captions.txt")
    if (( RT_CAPTIONS == 1 )); then
        [ -n "${GOURCE_CAPTION_SIZE}" ]         && gource_arg_array+=("--caption-size" "${GOURCE_CAPTION_SIZE}")
        [ -n "${GOURCE_CAPTION_COLOR}" ]        && gource_arg_array+=("--caption-colour" "${GOURCE_CAPTION_COLOR}")
        [ -n "${GOURCE_CAPTION_DURATION}" ]     && gource_arg_array+=("--caption-duration" "${GOURCE_CAPTION_DURATION}")
    fi

    # Avatars
    (( RT_AVATARS == 1 ))                       && gource_arg_array+=("--user-image-dir" "${ER_ROOT_DIRECTORY}/resources/avatars")

    # Background Image
    (( RT_BACKGROUND_IMAGE == 1 ))              && gource_arg_array+=("--background-image" "${ER_ROOT_DIRECTORY}/resources/background.image")

    # Default User Image
    (( RT_DEFAULT_USER_IMAGE == 1 ))            && gource_arg_array+=("--default-user-image" "${ER_ROOT_DIRECTORY}/resources/default_user.image")

    # Nightly
    if (( RT_NIGHTLY == 1 )); then
        [ "${GOURCE_FILE_EXT_FALLBACK}" = "1" ] && gource_arg_array+=("--file-extension-fallback")
    fi
    return 0
}
readonly -f gen_gource_args


# gen_ffmpeg_flags
# Sets a number of variables and flags used by the ffmepg execution step.
#
#
# Consumes:
#   RENDER_INVERT_COLORS
#   LOGO
#   LIVE_PREVIEW
#   PREVIEW_SLOWDOWN_FACTOR (optional)
#   RENDER_FPS
#   logo_ffmpeg_label
# Arguments:
#   none
# Outputs:
#   invert_filter (depend -> RENDER_INVERT_COLORS)
#   primary_map_label
#   logo_filter_graph (depend -> LOGO)
#   live_preview_args (depend -> LIVE_PREVIEW)
#   live_preview_splitter (depend -> LIVE_PREVIEW)
gen_ffmpeg_flags()
{
    if [ "${RENDER_INVERT_COLORS}" == "1" ]; then
        declare -gr invert_filter=",lutrgb=r=negval:g=negval:b=negval"
    fi

    # Default map
    declare -g primary_map_label="[default]"
    if (( RT_LOGO == 1 )); then
        if [ ! -n "${logo_ffmpeg_label}" ]; then
            log_error "Error: logo_ffmpeg_label variable must be set when using logo for ffmpeg (internal error)."
            return 1
        fi
        declare -gr logo_filter_graph=";${primary_map_label}${logo_ffmpeg_label}overlay=main_w-overlay_w-40:main_h-overlay_h-40[with_logo]"
        primary_map_label="[with_logo]"
        declare -gr logo_input=("-i" "${ER_ROOT_DIRECTORY}/resources/logo_txfrmed.image")
    fi

    if (( RT_LIVE_PREVIEW == 1 )); then
        declare -g live_preview_splitter live_preview_args
        : "${PREVIEW_SLOWDOWN_FACTOR:=1}"
        declare -i lp_fps=$((${RENDER_FPS} / ${PREVIEW_SLOWDOWN_FACTOR}))
        if (( lp_fps == 0 )); then
            log_error "Error: PREVIEW_SLOWDOWN_FACTOR is too large for given RENDER_FPS."
            return 1
        fi
        declare -gr live_preview_splitter="$( \
            printf "%s" \
                ";${primary_map_label}split[original_feed][time_scaler];" \
                "[time_scaler]setpts=${PREVIEW_SLOWDOWN_FACTOR}*PTS[live_preview]" \
        )"
        primary_map_label="[original_feed]"
        declare -gar live_preview_args=( \
            -map [live_preview] -c:v libx264 -pix_fmt yuv420p -maxrate 40M -bufsize 5M \
            -profile:v high -level:v 5.2 -y -r "${lp_fps}" -preset ultrafast -crf 1 \
                -tune zerolatency -x264-params keyint=$((lp_fps * 3)):min-keyint="${lp_fps}" \
                -vsync vfr -hls_flags independent_segments+delete_segments -hls_allow_cache 1 \
                -hls_time 1 -hls_list_size 10 -start_number 0 ./html/preview.m3u8 \
        )
    fi

    readonly primary_map_label
    return 0
}
readonly -f gen_ffmpeg_flags
