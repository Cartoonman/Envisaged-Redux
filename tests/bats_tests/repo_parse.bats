#!/usr/bin/env bats

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

load common/bats_common


@test "Test Repo Parse" {
    export COUNT=1
    mv "${ER_ROOT_DIRECTORY}"/git_repo "${ER_ROOT_DIRECTORY}"/old_git_repo
    ln -sf "${ER_ROOT_DIRECTORY}"/git_sandbox/repo1 "${ER_ROOT_DIRECTORY}"/git_repo
    # Baseline Recurse
    repo_run 
    repo_run RUNTIME_RECURSE_SUBMODULES=1
    # Control
    rm "${ER_ROOT_DIRECTORY}"/git_repo
    ln -sf "${ER_ROOT_DIRECTORY}"/git_sandbox/repo2 "${ER_ROOT_DIRECTORY}"/git_repo
    repo_run 
    repo_run RUNTIME_RECURSE_SUBMODULES=1
    # Multi Setting
    rm "${ER_ROOT_DIRECTORY}"/git_repo
    ln -sf "${ER_ROOT_DIRECTORY}"/git_sandbox "${ER_ROOT_DIRECTORY}"/git_repo
    repo_run 
    repo_run RUNTIME_RECURSE_SUBMODULES=1

    rm "${ER_ROOT_DIRECTORY}"/git_repo
    mv "${ER_ROOT_DIRECTORY}"/old_git_repo "${ER_ROOT_DIRECTORY}"/git_repo
    (( SAVE == 1 )) && skip || :
}

