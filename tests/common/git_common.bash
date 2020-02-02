#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

gen_commit()
{
    local -r GIT_DIR_PATH=$1 && shift
    local -r USR_NME=$1 && shift
    local -r USR_EML=$1 && shift
    local -r CMT_MSG=$1 && shift
    cd $GIT_DIR_PATH
    while [[ $# -ne 0 ]]; do
        if [[ "$1" =~ '>>' ]]; then
            SAVEIFS=$IFS && IFS='>>' && CMD_ARR=($1) && IFS=$SAVEIFS
            FILES=$(find ${CMD_ARR[2]})
            SAVEIFS=$IFS && IFS=$'\n' && FILES=($FILES) && IFS=$SAVEIFS
            echo "datadatadata" | tee -a "${FILES[@]}" > /dev/null 2>&1
        else
            $1
        fi
        shift
    done
    git config user.name "$USR_NME"
    git config user.email "$USR_EML"
    export GIT_AUTHOR_DATE="$TS -0000"
    export GIT_COMMITTER_DATE="$TS +0000"
    git add .
    git commit -m "$CMT_MSG"
    TS=$(( $TS+$RANDOM ))
}
