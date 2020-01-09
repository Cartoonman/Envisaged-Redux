#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0


COLOR_ERROR='\e[31m'
COLOR_WARN='\e[33m'
COLOR_INFO='\e[96m'
COLOR_OK='\e[92m'
COLOR_NOTICE='\e[93m'
NC='\e[0m'

function log_error
{
    >&2 echo -e "${COLOR_ERROR}[ERROR] ${1}${NC}"
}
function log_warn
{
    echo -e "${COLOR_WARN}[WARN] ${1}${NC}"
}
function log_notice
{
    echo -e "${COLOR_NOTICE}[NOTE] ${1}${NC}"
}
function log_info
{
    echo -e "${COLOR_INFO}[INFO] ${1}${NC}"
}
function log_success
{
    echo -e "${COLOR_OK}[OK] ${1}${NC}"
}
