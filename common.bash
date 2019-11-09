#!/bin/bash

# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: MIT

COLOR_RED='\e[31m'
COLOR_MAGENTA='\e[95m'
COLOR_CYAN='\e[96m'
COLOR_GREEN='\e[92m'
COLOR_YELLOW='\e[93m'
NC='\e[0m'

function log_error
{
	echo -e "${COLOR_RED}${1}${NC}"
}
function log_warn
{
	echo -e "${COLOR_MAGENTA}${1}${NC}"
}
function log_notice
{
	echo -e "${COLOR_YELLOW}${1}${NC}"
}
function log_info
{
	echo -e "${COLOR_CYAN}${1}${NC}"
}
function log_success
{
	echo -e "${COLOR_GREEN}${1}${NC}"
}
