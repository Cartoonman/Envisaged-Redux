#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

inc_dir_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${inc_dir_path}/common.bash"
unset inc_dir_path

# Assign defaults if not set
: "${H265_PRESET:=medium}"
: "${H265_CRF:=21}"
: "${VIDEO_RESOLUTION:=1080p}"
: "${FPS:=30}"

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
function gen_gource_args
{
    gource_arg_array=()

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
    [ -n "${GOURCE_DIR_DEPTH}" ]                && gource_arg_array+=("--dir-name-depth" "${GOURCE_DIR_DEPTH}")
    [ -n "${GOURCE_BLOOM_MULTIPLIER}" ]         && gource_arg_array+=("--bloom-multiplier" "${GOURCE_BLOOM_MULTIPLIER}")
    [ -n "${GOURCE_BLOOM_INTENSITY}" ]          && gource_arg_array+=("--bloom-intensity" "${GOURCE_BLOOM_INTENSITY}")
    [ -n "${GOURCE_PADDING}" ]                  && gource_arg_array+=("--padding" "${GOURCE_PADDING}")

    [ "${GOURCE_HIGHLIGHT_ALL_USERS}" = "1" ]   && gource_arg_array+=("--highlight-users")
    [ "${GOURCE_MULTI_SAMPLING}" = "1" ]        && gource_arg_array+=("--multi-sampling")
    [ "${GOURCE_SHOW_KEY}" = "1" ]              && gource_arg_array+=("--key")

    # Captions
    [ "${USE_CAPTIONS}" = "1" ]                 && gource_arg_array+=("--caption-file" "/visualization/captions.txt")
    if [ "${USE_CAPTIONS}" = "1" ]; then
        [ -n "${GOURCE_CAPTION_SIZE}" ]         && gource_arg_array+=("--caption-size" "${GOURCE_CAPTION_SIZE}")
        [ -n "${GOURCE_CAPTION_COLOR}" ]        && gource_arg_array+=("--caption-colour" "${GOURCE_CAPTION_COLOR}")
        [ -n "${GOURCE_CAPTION_DURATION}" ]     && gource_arg_array+=("--caption-duration" "${GOURCE_CAPTION_DURATION}")
    fi

    # Avatars
    [ "${USE_AVATARS}" = "1" ]                  && gource_arg_array+=("--user-image-dir" "/visualization/avatars")

    # Nightly
    if [ "${USE_NIGHTLY}" = "1" ]; then
        [ "${GOURCE_FILE_EXT_FALLBACK}" = "1" ] && gource_arg_array+=("--file-extension-fallback")
    fi
}
readonly -f gen_gource_args


# gen_ffmpeg_flags
# Sets a number of variables and flags used by the ffmepg execution step.
#
#
# Consumes:
#   INVERT_COLORS
#   LOGO
#   LIVE_PREVIEW
#   PREVIEW_SLOWDOWN_FACTOR (optional)
#   FPS
#   logo_ffmpeg_label
# Arguments:
#   none
# Outputs:
#   invert_filter (depend -> INVERT_COLORS)
#   primary_map_label
#   logo_filter_graph (depend -> LOGO)
#   live_preview_args (depend -> LIVE_PREVIEW)
#   live_preview_splitter (depend -> LIVE_PREVIEW)
function gen_ffmpeg_flags
{
    if [ "${INVERT_COLORS}" == "1" ]; then
        invert_filter=",lutrgb=r=negval:g=negval:b=negval"
    fi

    # Default map
    declare -g primary_map_label="[default]"
    if [ "${LOGO}" != "" ]; then
        declare -g logo_filter_graph
        [ -z "${logo_ffmpeg_label+x}" ] && log_error "Error: logo_ffmpeg_label variable must be set when using logo for ffmpeg (internal error)." && exit 1
        logo_filter_graph=";${primary_map_label}${logo_ffmpeg_label}overlay=main_w-overlay_w-40:main_h-overlay_h-40[with_logo]"
        primary_map_label="[with_logo]"
    fi

    if [ "${LIVE_PREVIEW}" = "1" ]; then
        declare -g live_preview_splitter live_preview_args
        : "${PREVIEW_SLOWDOWN_FACTOR:=1}"
        local lp_fps=$((${FPS} / ${PREVIEW_SLOWDOWN_FACTOR}))

        live_preview_splitter=";${primary_map_label}split[original_feed][time_scaler]; \
            [time_scaler]setpts=${PREVIEW_SLOWDOWN_FACTOR}*PTS[live_preview]"
        primary_map_label="[original_feed]"
        live_preview_args=" -map [live_preview] -c:v libx264 -pix_fmt yuv420p -maxrate 40M -bufsize 5M \
            -profile:v high -level:v 5.2 -y -r ${lp_fps} -preset ultrafast -crf 1 \
            -tune zerolatency -x264-params keyint=$((${lp_fps} * 3)):min-keyint=${lp_fps} \
            -vsync vfr -hls_flags independent_segments+delete_segments -hls_allow_cache 1 \
            -hls_time 1 -hls_list_size 10 -start_number 0 ./html/preview.m3u8"
    fi
}
readonly -f gen_ffmpeg_flags
