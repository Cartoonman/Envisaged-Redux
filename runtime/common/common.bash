#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

# Constants
readonly ER_ROOT_DIRECTORY="/visualization"

log_error()
{
    declare -r red="\e[31m"
    >&2 printf "%b %s\n" "${red}\033[1m[ERROR]\e[0m" "${1}"
}
log_warn()
{
    declare -r orange="\e[31m"
    printf "%b  %s\n" "${orange}\033[1m[WARN]\e[0m" "${1}"
}
log_notice()
{
    declare -r yellow="\e[93m"
    printf "%b  %s\n" "${yellow}\033[1m[NOTE]\e[0m" "${1}"
}
log_info()
{
    declare -r cyan="\e[96m"
    printf "%b  %s\n" "${cyan}\033[1m[INFO]\e[0m" "${1}"
}
log_success()
{
    declare -r green="\e[92m"
    printf "%b  %s\n" "${green}\033[1m[OKAY]\e[0m" "${1}"
}

readonly -f log_error
readonly -f log_warn
readonly -f log_notice
readonly -f log_info
readonly -f log_success

# Set the common global flag
readonly ER_COMMON_GLOBAL=1
