#!/usr/bin/env bats

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

load common/bats_common


@test "Test Repo Parse" {
    export COUNT=1
    mv /visualization/git_repo /visualization/old_git_repo
    ln -sf /visualization/git_sandbox/repo1 /visualization/git_repo
    # Baseline Recurse
    repo_run 
    repo_run RECURSE_SUBMODULES=1
    # Control
    rm /visualization/git_repo
    ln -sf /visualization/git_sandbox/repo2 /visualization/git_repo
    repo_run 
    repo_run RECURSE_SUBMODULES=1
    # Multi Setting
    rm /visualization/git_repo
    ln -sf /visualization/git_sandbox /visualization/git_repo
    repo_run 
    repo_run RECURSE_SUBMODULES=1

    rm /visualization/git_repo
    mv /visualization/old_git_repo /visualization/git_repo
    [ "${SAVE}" = "1" ] && skip || :
}

