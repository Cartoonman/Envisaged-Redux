#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

# Constants
readonly ER_ROOT_DIRECTORY="/visualization"

log_error()
{
    declare -r red="\e[31m"
    >&2 printf "%b %s\n" "${red}\033[1m[ERROR]\e[0m" "$1"
    return 0
}
readonly -f log_error

log_warn()
{
    declare -r yellow="\e[33m"
    printf "%b  %s\n" "${yellow}\033[1m[WARN]\e[0m" "$1"
    return 0
}
readonly -f log_warn

log_notice()
{
    declare -r magenta="\e[35m"
    printf "%b  %s\n" "${magenta}\033[1m[NOTE]\e[0m" "$1"
    return 0
}
readonly -f log_notice

log_info()
{
    declare -r cyan="\e[36m"
    printf "%b  %s\n" "${cyan}\033[1m[INFO]\e[0m" "$1"
    return 0
}
readonly -f log_info

log_success()
{
    declare -r green="\e[32m"
    printf "%b  %s\n" "${green}\033[1m[OKAY]\e[0m" "$1"
    return 0
}
readonly -f log_success

log_debug()
{
    declare -r blue="\e[34m"
    (( RT_DEBUG == 1 )) && printf "%b %s\n" "${blue}\033[1m[DEBUG]\e[0m" "$1"
    return 0
}
readonly -f log_debug

stop_process()
{
    [ -n "$1" ] && [ -e /proc/"$1" ] && kill "$1"
    return 0
}
readonly -f stop_process


# Set the common global flag
readonly ER_COMMON_GLOBAL=1
