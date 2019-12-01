#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: MIT

COLOR_RED='\e[31m'
COLOR_MAGENTA='\e[95m'
COLOR_CYAN='\e[96m'
COLOR_GREEN='\e[92m'
COLOR_YELLOW='\e[93m'
NC='\e[0m'

XVFB_TIMEOUT=60

# Assign defaults if not set
: "${H265_PRESET:=medium}"
: "${H265_CRF:=21}"
: "${VIDEO_RESOLUTION:=1080p}"
: "${FPS:=30}"

function print_intro
{
cat << "EOF"
 _____            _                          _    ____          _
| ____|_ ____   _(_)___  __ _  __ _  ___  __| |  |  _ \ ___  __| |_   ___  __
|  _| | '_ \ \ / / / __|/ _` |/ _` |/ _ \/ _` |  | |_) / _ \/ _` | | | \ \/ /
| |___| | | \ V /| \__ \ (_| | (_| |  __/ (_| |  |  _ <  __/ (_| | |_| |>  <
|_____|_| |_|\_/ |_|___/\__,_|\__, |\___|\__,_|  |_| \_\___|\__,_|\__,_/_/\_\
******************************|___/******************************************

EOF
}

function log_error
{
    >&2 echo -e "${COLOR_RED}[ERROR] ${1}${NC}"
}
function log_warn
{
    echo -e "${COLOR_MAGENTA}[WARN] ${1}${NC}"
}
function log_notice
{
    echo -e "${COLOR_YELLOW}[NOTICE] ${1}${NC}"
}
function log_info
{
    echo -e "${COLOR_CYAN}[INFO] ${1}${NC}"
}
function log_success
{
    echo -e "${COLOR_GREEN}[OK] ${1}${NC}"
}


function gen_gource_args
{
    GOURCE_ARG_ARRAY=()

    [ -n "${GOURCE_TITLE}" ]                    && GOURCE_ARG_ARRAY+=("--title" "${GOURCE_TITLE}")
    [ -n "${GOURCE_CAMERA_MODE}" ]              && GOURCE_ARG_ARRAY+=("--camera-mode" "${GOURCE_CAMERA_MODE}")
    [ -n "${GOURCE_START_DATE}" ]               && GOURCE_ARG_ARRAY+=("--start-date" "${GOURCE_START_DATE}")
    [ -n "${GOURCE_STOP_DATE}" ]                && GOURCE_ARG_ARRAY+=("--stop-date" "${GOURCE_STOP_DATE}")
    [ -n "${GOURCE_START_POSITION}" ]           && GOURCE_ARG_ARRAY+=("--start-position" "${GOURCE_START_POSITION}")
    [ -n "${GOURCE_STOP_POSITION}" ]            && GOURCE_ARG_ARRAY+=("--stop-position" "${GOURCE_STOP_POSITION}")
    [ -n "${GOURCE_STOP_AT_TIME}" ]             && GOURCE_ARG_ARRAY+=("--stop-at-time" "${GOURCE_STOP_AT_TIME}")
    [ -n "${GOURCE_SECONDS_PER_DAY}" ]          && GOURCE_ARG_ARRAY+=("--seconds-per-day" "${GOURCE_SECONDS_PER_DAY}")
    [ -n "${GOURCE_AUTO_SKIP_SECONDS}" ]        && GOURCE_ARG_ARRAY+=("--auto-skip-seconds" "${GOURCE_AUTO_SKIP_SECONDS}")
    [ -n "${GOURCE_TIME_SCALE}" ]               && GOURCE_ARG_ARRAY+=("--time-scale" "${GOURCE_TIME_SCALE}")
    [ -n "${GOURCE_USER_SCALE}" ]               && GOURCE_ARG_ARRAY+=("--user-scale" "${GOURCE_USER_SCALE}")
    [ -n "${GOURCE_MAX_USER_SPEED}" ]           && GOURCE_ARG_ARRAY+=("--max-user-speed" "${GOURCE_MAX_USER_SPEED}")
    [ -n "${GOURCE_HIDE_ITEMS}" ]               && GOURCE_ARG_ARRAY+=("--hide" "${GOURCE_HIDE_ITEMS}")
    [ -n "${GOURCE_FILE_IDLE_TIME}" ]           && GOURCE_ARG_ARRAY+=("--file-idle-time" "${GOURCE_FILE_IDLE_TIME}")
    [ -n "${GOURCE_MAX_FILES}" ]                && GOURCE_ARG_ARRAY+=("--max-files" "${GOURCE_MAX_FILES}")
    [ -n "${GOURCE_MAX_FILE_LAG}" ]             && GOURCE_ARG_ARRAY+=("--max-file-lag" "${GOURCE_MAX_FILE_LAG}")
    [ -n "${GOURCE_FILENAME_TIME}" ]            && GOURCE_ARG_ARRAY+=("--filename-time" "${GOURCE_FILENAME_TIME}")
    [ -n "${GOURCE_FONT_SIZE}" ]                && GOURCE_ARG_ARRAY+=("--font-size" "${GOURCE_FONT_SIZE}")
    [ -n "${GOURCE_FONT_COLOR}" ]               && GOURCE_ARG_ARRAY+=("--font-colour" "${GOURCE_FONT_COLOR}")
    [ -n "${GOURCE_BACKGROUND_COLOR}" ]         && GOURCE_ARG_ARRAY+=("--background-colour" "${GOURCE_BACKGROUND_COLOR}")
    [ -n "${GOURCE_DATE_FORMAT}" ]              && GOURCE_ARG_ARRAY+=("--date-format" "${GOURCE_DATE_FORMAT}")
    [ -n "${GOURCE_DIR_DEPTH}" ]                && GOURCE_ARG_ARRAY+=("--dir-name-depth" "${GOURCE_DIR_DEPTH}")
    [ -n "${GOURCE_BLOOM_MULTIPLIER}" ]         && GOURCE_ARG_ARRAY+=("--bloom-multiplier" "${GOURCE_BLOOM_MULTIPLIER}")
    [ -n "${GOURCE_BLOOM_INTENSITY}" ]          && GOURCE_ARG_ARRAY+=("--bloom-intensity" "${GOURCE_BLOOM_INTENSITY}")
    [ -n "${GOURCE_PADDING}" ]                  && GOURCE_ARG_ARRAY+=("--padding" "${GOURCE_PADDING}")

    [ "${GOURCE_HIGHLIGHT_ALL_USERS}" = "1" ]   && GOURCE_ARG_ARRAY+=("--highlight-users")
    [ "${GOURCE_MULTI_SAMPLING}" = "1" ]        && GOURCE_ARG_ARRAY+=("--multi-sampling")
    [ "${GOURCE_SHOW_KEY}" = "1" ]              && GOURCE_ARG_ARRAY+=("--key")

    # Captions
    [ "${USE_CAPTIONS}" = "1" ]                 && GOURCE_ARG_ARRAY+=("--caption-file" "/visualization/captions.txt")
    if [ "${USE_CAPTIONS}" = "1" ]; then
        [ -n "${GOURCE_CAPTION_SIZE}" ]         && GOURCE_ARG_ARRAY+=("--caption-size" "${GOURCE_CAPTION_SIZE}")
        [ -n "${GOURCE_CAPTION_COLOR}" ]        && GOURCE_ARG_ARRAY+=("--caption-colour" "${GOURCE_CAPTION_COLOR}")
        [ -n "${GOURCE_CAPTION_DURATION}" ]     && GOURCE_ARG_ARRAY+=("--caption-duration" "${GOURCE_CAPTION_DURATION}")
    fi

    # Avatars
    [ "${USE_AVATARS}" = "1" ]                  && GOURCE_ARG_ARRAY+=("--user-image-dir" "/visualization/avatars")

    # Nightly
    if [ "${USE_NIGHTLY}" = "1" ]; then
        [ "${GOURCE_FILE_EXT_FALLBACK}" = "1" ] && GOURCE_ARG_ARRAY+=("--file-extension-fallback")
    fi
}


function gen_ffmpeg_flags
{
    if [ "${INVERT_COLORS}" == "1" ]; then
        INVERT_FILTER=",lutrgb=r=negval:g=negval:b=negval"
    fi

    # Default map
    PRIMARY_MAP_LABEL="[default]"
    if [ "${LOGO}" != "" ]; then
        [ -z "${LOGO_FFMPEG_LABEL}" ] && log_error "Error: LOGO_FFMPEG_LABEL variable must be set when using logo for ffmpeg (internal error)." && exit 1
        LOGO_FILTER_GRAPH=";${PRIMARY_MAP_LABEL}${LOGO_FFMPEG_LABEL}overlay=main_w-overlay_w-40:main_h-overlay_h-40[with_logo]"
        PRIMARY_MAP_LABEL="[with_logo]"
    fi

    if [ "${LIVE_PREVIEW}" = "1" ]; then
        : "${PREVIEW_SLOWDOWN_FACTOR:=1}"
        LP_FPS=$((${FPS} / ${PREVIEW_SLOWDOWN_FACTOR}))
        LIVE_PREVIEW_SPLITTER=";${PRIMARY_MAP_LABEL}split[original_feed][time_scaler]; \
            [time_scaler]setpts=${PREVIEW_SLOWDOWN_FACTOR}*PTS[live_preview]"
        PRIMARY_MAP_LABEL="[original_feed]"
        LIVE_PREVIEW_ARGS=" -map [live_preview] -c:v libx264 -pix_fmt yuv420p -maxrate 40M -bufsize 2M \
            -profile:v high -level:v 5.2 -y -r ${LP_FPS} -preset ultrafast -crf 1 \
            -tune zerolatency -x264-params keyint=$((${LP_FPS} * 3)):min-keyint=${LP_FPS} \
            -vsync vfr -hls_flags independent_segments+delete_segments -hls_allow_cache 1 \
            -hls_time 1 -hls_list_size 10 -start_number 0 ./html/preview.m3u8"
    fi
}

function parse_args
{
    while [[ $# -gt 0 ]]; do
        k="$1"
        case $k in
            HOLD)
                log_info "Test mode enabled. Spinning main thread. Run docker stop on container when complete."
                trap 'exit 143' SIGTERM # exit = 128 + 15 (SIGTERM)
                tail -f /dev/null & wait ${!}
                exit 0
                ;;
            TEST)
                export TEST=1
                log_warn "TEST Flag Invoked"
                ;;
            NORUN)
                export NORUN=1
                log_warn "NORUN Flag Invoked"
                ;;
        esac
        shift
    done
}

