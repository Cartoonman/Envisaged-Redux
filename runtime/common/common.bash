#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

# Constants
readonly ER_ROOT_DIRECTORY="/visualization"

declare -gr _ER_RED="\e[31m"
declare -gr _ER_YELLOW="\e[33m"
declare -gr _ER_MAGENTA="\e[35m"
declare -gr _ER_CYAN="\e[36m"
declare -gr _ER_GREEN="\e[32m"
declare -gr _ER_BLUE="\e[34m"

declare -gr _ER_ERROR_STRING="${_ER_RED}\033[1m[ERROR]\e[0m"
declare -gr _ER_WARN_STRING="${_ER_YELLOW}\033[1m[WARN]\e[0m"
declare -gr _ER_NOTICE_STRING="${_ER_MAGENTA}\033[1m[NOTE]\e[0m"
declare -gr _ER_INFO_STRING="${_ER_CYAN}\033[1m[INFO]\e[0m"
declare -gr _ER_SUCCESS_STRING="${_ER_GREEN}\033[1m[OKAY]\e[0m"
declare -gr _ER_DEBUG_STRING="${_ER_BLUE}\033[1m[DEBUG]\e[0m"

log_error()
{
    declare -r red="\e[31m"
    >&2 printf "%b %s\n" "${_ER_ERROR_STRING}" "$1"
    return 0
}
readonly -f log_error

log_warn()
{
    declare -r yellow="\e[33m"
    printf "%b  %s\n" "${_ER_WARN_STRING}" "$1"
    return 0
}
readonly -f log_warn

log_notice()
{
    declare -r magenta="\e[35m"
    printf "%b  %s\n" "${_ER_NOTICE_STRING}" "$1"
    return 0
}
readonly -f log_notice

log_info()
{
    declare -r cyan="\e[36m"
    printf "%b  %s\n" "${_ER_INFO_STRING}" "$1"
    return 0
}
readonly -f log_info

log_success()
{
    declare -r green="\e[32m"
    printf "%b  %s\n" "${_ER_SUCCESS_STRING}" "$1"
    return 0
}
readonly -f log_success

log_debug()
{
    declare -r blue="\e[34m"
    (( RT_DEBUG == 1 )) && printf "%b %s\n" "${_ER_DEBUG_STRING}" "$1"
    return 0
}
readonly -f log_debug

stop_process()
{
    [ -n "$1" ] && [ -e "/proc/$1" ] && kill "$1"
    return 0
}
readonly -f stop_process


# Set the common global flag
readonly ER_COMMON_GLOBAL=1
