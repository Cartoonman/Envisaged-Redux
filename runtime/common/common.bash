#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

# Constants
declare -r ER_COLOR_ERROR='\e[31m'
declare -r ER_COLOR_WARN='\e[33m'
declare -r ER_COLOR_INFO='\e[96m'
declare -r ER_COLOR_OK='\e[92m'
declare -r ER_COLOR_NOTICE='\e[93m'
declare -r ER_NC='\e[0m'

function log_error
{
    >&2 echo -e "${ER_COLOR_ERROR}[ERROR] ${1}${ER_NC}"
}
function log_warn
{
    echo -e "${ER_COLOR_WARN}[WARN] ${1}${ER_NC}"
}
function log_notice
{
    echo -e "${ER_COLOR_NOTICE}[NOTE] ${1}${ER_NC}"
}
function log_info
{
    echo -e "${ER_COLOR_INFO}[INFO] ${1}${ER_NC}"
}
function log_success
{
    echo -e "${ER_COLOR_OK}[OK] ${1}${ER_NC}"
}

readonly -f log_error
readonly -f log_warn
readonly -f log_notice
readonly -f log_info
readonly -f log_success

# Set the common global flag
declare -r ER_COMMON_GLOBAL=1