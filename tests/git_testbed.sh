#!/bin/bash

# Envisaged Redux
# Copyright (c) 2020 Carl Colena
#
# SPDX-License-Identifier: Apache-2.0

CUR_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly CUR_DIR_PATH
source "${CUR_DIR_PATH}"/common/git_common.bash

parent_dir="$1"

mkdir -p "${parent_dir}"
cd "${parent_dir}"
mkdir repo1
mkdir repo2
mkdir repo3
mkdir not_a_repo
touch not_a_repo/file.txt
mkdir also_not_a_repo
touch also_not_a_repo/file.txt
cd "${parent_dir}"/repo1
git init
cd "${parent_dir}"/repo2
git init
cd "${parent_dir}"/repo3
git init
# Seed
RANDOM=8374
TIMESTAMP=1358795000

work_cmd=("touch README.md" "touch Makefile")
gen_commit "${parent_dir}"/repo1 "John Doe" "john@doe.org" "init_commit" "${work_cmd[@]}"
work_cmd=("mkdir -p src/" "touch src/test1.cpp" "touch src/test2.cpp" "touch src/test3.cpp" "mkdir -p include/" "touch include/test1.hpp" "touch include/test2.hpp" "touch include/test3.hpp")
gen_commit "${parent_dir}"/repo1 "John Doe" "john@doe.org" "commit 2" "${work_cmd[@]}"
work_cmd=(">> src/*.cpp" ">> include/*.hpp")
gen_commit "${parent_dir}"/repo1 "John Doe" "john@doe.org" "commit 3" "${work_cmd[@]}"
work_cmd=(">> README.md")
gen_commit "${parent_dir}"/repo1 "John Doe" "john@doe.org" "commit 4" "${work_cmd[@]}"
work_cmd=(">> README.md")
gen_commit "${parent_dir}"/repo1 "OtherPerson" "other@person.org" "commit 5" "${work_cmd[@]}"
work_cmd=(">> src/test1.cpp" ">> src/test3.cpp")
gen_commit "${parent_dir}"/repo1 "Third" "third@person.org" "commit 6" "${work_cmd[@]}"
work_cmd=(">> src/*.cpp")
gen_commit "${parent_dir}"/repo1 "John Doe" "john@doe.org"  "commit 7" "${work_cmd[@]}"
work_cmd=("mkdir -p src/p1" "touch src/p1/test1.cpp" "touch src/p1/test1.cpp")
gen_commit "${parent_dir}"/repo1 "OtherPerson" "other@person.org"  "commit 8" "${work_cmd[@]}"
work_cmd=(">> include/*.hpp")

work_cmd=("touch README.md" "touch Makefile")
gen_commit "${parent_dir}"/repo2 "John Doe" "john@doe.org" "init_commit" "${work_cmd[@]}"
work_cmd=("mkdir -p src/" "touch src/test1.cpp" "touch src/test2.cpp" "touch src/test3.cpp" "mkdir -p include/" "touch include/test1.hpp" "touch include/test2.hpp" "touch include/test3.hpp")
gen_commit "${parent_dir}"/repo2 "John Doe" "john@doe.org" "commit 2" "${work_cmd[@]}"
work_cmd=(">> src/*.cpp" ">> include/*.hpp")
work_cmd=("touch README.md" "touch Makefile")
gen_commit "${parent_dir}"/repo3 "Jane Doe" "Jane@doe.org" "init_commit" "${work_cmd[@]}"
work_cmd=("mkdir -p src/" "touch src/test1.cpp" "touch src/test2.cpp" "touch src/test3.cpp" "mkdir -p include/" "touch include/test1.hpp" "touch include/test2.hpp" "touch include/test3.hpp")
gen_commit "${parent_dir}"/repo3 "Jane Doe" "Jane@doe.org" "commit 2" "${work_cmd[@]}"
work_cmd=(">> src/*.cpp" ">> include/*.hpp")
gen_commit "${parent_dir}"/repo3 "John Doe" "john@doe.org" "commit 3" "${work_cmd[@]}"
work_cmd=(">> README.md")
gen_commit "${parent_dir}"/repo3 "John Doe" "john@doe.org" "commit 4" "${work_cmd[@]}"
work_cmd=(">> README.md")
gen_commit "${parent_dir}"/repo2 "OtherPerson" "other@person.org" "commit 5" "${work_cmd[@]}"
work_cmd=(">> src/test1.cpp" ">> src/test3.cpp")
gen_commit "${parent_dir}"/repo3 "Third" "third@person.org" "commit 6" "${work_cmd[@]}"
work_cmd=(">> src/*.cpp")
gen_commit "${parent_dir}"/repo2 "John Doe" "john@doe.org"  "commit 7" "${work_cmd[@]}"
work_cmd=("mkdir -p src/p1" "touch src/p1/test1.cpp" "touch src/p1/test1.cpp")
gen_commit "${parent_dir}"/repo3 "OtherPerson" "other@person.org"  "commit 8" "${work_cmd[@]}"
work_cmd=(">> include/*.hpp")

# Add submodule to repo 1
mkdir -p "${parent_dir}"/repo1/src/submod1
cd "${parent_dir}"/repo1/src/submod1
git init
work_cmd=("touch README.md" "touch Makefile")
gen_commit "${parent_dir}"/repo1/src/submod1 "John Doe" "john@doe.org" "init_commit" "${work_cmd[@]}"
work_cmd=("mkdir -p src/" "touch src/test1.cpp" "touch src/test2.cpp" "touch src/test3.cpp" "mkdir -p include/" "touch include/test1.hpp" "touch include/test2.hpp" "touch include/test3.hpp")
gen_commit "${parent_dir}"/repo1/src/submod1 "John Doe" "john@doe.org" "commit 2" "${work_cmd[@]}"
work_cmd=("git submodule add ./src/submod1/ src/submod1")
gen_commit "${parent_dir}"/repo1 "John Doe" "john@doe.org" "adding submodule" "${work_cmd[@]}"
work_cmd=(">> README.md" "touch LICENSE")
gen_commit "${parent_dir}"/repo1 "OtherPerson" "other@person.org" "commit 5" "${work_cmd[@]}"
work_cmd=("mkdir -p src/p1" "touch src/p1/test1.cpp" "touch src/p1/test1.cpp")
gen_commit "${parent_dir}"/repo1/src/submod1 "John Doe" "john@doe.org" "commit 3" "${work_cmd[@]}"
work_cmd=(">> README.md")
gen_commit "${parent_dir}"/repo1 "John Doe" "john@doe.org" "commit 7" "${work_cmd[@]}"

# Add a nested submodule to repo 1's submodule.
mkdir -p "${parent_dir}"/repo1/src/submod1/src/submod2
cd "${parent_dir}"/repo1/src/submod1/src/submod2
git init
work_cmd=("touch README.md" "touch Makefile")
gen_commit "${parent_dir}"/repo1/src/submod1/src/submod2 "John Doe" "john@doe.org" "init_commit" "${work_cmd[@]}"
work_cmd=("mkdir -p src/" "touch src/test1.cpp" "touch src/test2.cpp" "touch src/test3.cpp" "mkdir -p include/" "touch include/test1.hpp" "touch include/test2.hpp" "touch include/test3.hpp")
gen_commit "${parent_dir}"/repo1/src/submod1/src/submod2 "John Doe" "john@doe.org" "commit 2" "${work_cmd[@]}"
work_cmd=("git submodule add ./src/submod2/ src/submod2")
gen_commit "${parent_dir}"/repo1/src/submod1 "John Doe" "john@doe.org" "adding submodule" "${work_cmd[@]}"
work_cmd=(">> LICENSE")
gen_commit "${parent_dir}"/repo1 "John Doe" "john@doe.org" "adding subsubmodule" "${work_cmd[@]}"