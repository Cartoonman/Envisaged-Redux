#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

gen_commit()
{
    local -r git_dir_path="$1" && shift
    local -r user_name="$1" && shift
    local -r user_email="$1" && shift
    local -r commit_message="$1" && shift
    cd "${git_dir_path}"
    while [[ $# -ne 0 ]]; do
        if [[ "$1" =~ '>>' ]]; then
            readarray -d '>>' -t cmd_arr <<< "$1"
            files_to_write="$(find ${cmd_arr[2]})"
            readarray -d $'\n' -t files_to_write <<< "${files_to_write}"
            echo "datadatadata" | tee -a "${files_to_write[@]}" > /dev/null 2>&1
        else
            $1
        fi
        shift
    done
    git config user.name "${user_name}"
    git config user.email "${user_email}"
    export GIT_AUTHOR_DATE="${TIMESTAMP} -0000"
    export GIT_COMMITTER_DATE="${TIMESTAMP} +0000"
    git add .
    git commit -m "${commit_message}"
    TIMESTAMP="$(( TIMESTAMP + RANDOM ))"
}
