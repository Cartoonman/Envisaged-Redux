#!/bin/bash

# Envisaged Redux
# Copyright (c) 2019 Carl Colena
#
# SPDX-License-Identifier: MIT

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $DIR/common/git_common.bash

PARENT_DIR=$1

mkdir ${PARENT_DIR}
cd ${PARENT_DIR}
mkdir repo1
mkdir repo2
mkdir repo3
mkdir not_a_repo
touch not_a_repo/file.txt
mkdir also_not_a_repo
touch also_not_a_repo/file.txt
cd ${PARENT_DIR}/repo1
git init
cd ${PARENT_DIR}/repo2
git init
cd ${PARENT_DIR}/repo3
git init
# Seed
RANDOM=8374
TS=1358795000

CMD=("touch README.md" "touch Makefile")
gen_commit ${PARENT_DIR}/repo1 "John Doe" "john@doe.org" "init_commit" "${CMD[@]}"
CMD=("mkdir -p src/" "touch src/test1.cpp" "touch src/test2.cpp" "touch src/test3.cpp" "mkdir -p include/" "touch include/test1.hpp" "touch include/test2.hpp" "touch include/test3.hpp")
gen_commit ${PARENT_DIR}/repo1 "John Doe" "john@doe.org" "commit 2" "${CMD[@]}"
CMD=(">> src/*.cpp" ">> include/*.hpp")
gen_commit ${PARENT_DIR}/repo1 "John Doe" "john@doe.org" "commit 3" "${CMD[@]}"
CMD=(">> README.md")
gen_commit ${PARENT_DIR}/repo1 "John Doe" "john@doe.org" "commit 4" "${CMD[@]}"
CMD=(">> README.md")
gen_commit ${PARENT_DIR}/repo1 "OtherPerson" "other@person.org" "commit 5" "${CMD[@]}"
CMD=(">> src/test1.cpp" ">> src/test3.cpp")
gen_commit ${PARENT_DIR}/repo1 "Third" "third@person.org" "commit 6" "${CMD[@]}"
CMD=(">> src/*.cpp")
gen_commit ${PARENT_DIR}/repo1 "John Doe" "john@doe.org"  "commit 7" "${CMD[@]}"
CMD=("mkdir -p src/p1" "touch src/p1/test1.cpp" "touch src/p1/test1.cpp")
gen_commit ${PARENT_DIR}/repo1 "OtherPerson" "other@person.org"  "commit 8" "${CMD[@]}"
CMD=(">> include/*.hpp")

CMD=("touch README.md" "touch Makefile")
gen_commit ${PARENT_DIR}/repo2 "John Doe" "john@doe.org" "init_commit" "${CMD[@]}"
CMD=("mkdir -p src/" "touch src/test1.cpp" "touch src/test2.cpp" "touch src/test3.cpp" "mkdir -p include/" "touch include/test1.hpp" "touch include/test2.hpp" "touch include/test3.hpp")
gen_commit ${PARENT_DIR}/repo2 "John Doe" "john@doe.org" "commit 2" "${CMD[@]}"
CMD=(">> src/*.cpp" ">> include/*.hpp")
CMD=("touch README.md" "touch Makefile")
gen_commit ${PARENT_DIR}/repo3 "Jane Doe" "Jane@doe.org" "init_commit" "${CMD[@]}"
CMD=("mkdir -p src/" "touch src/test1.cpp" "touch src/test2.cpp" "touch src/test3.cpp" "mkdir -p include/" "touch include/test1.hpp" "touch include/test2.hpp" "touch include/test3.hpp")
gen_commit ${PARENT_DIR}/repo3 "Jane Doe" "Jane@doe.org" "commit 2" "${CMD[@]}"
CMD=(">> src/*.cpp" ">> include/*.hpp")
gen_commit ${PARENT_DIR}/repo3 "John Doe" "john@doe.org" "commit 3" "${CMD[@]}"
CMD=(">> README.md")
gen_commit ${PARENT_DIR}/repo3 "John Doe" "john@doe.org" "commit 4" "${CMD[@]}"
CMD=(">> README.md")
gen_commit ${PARENT_DIR}/repo2 "OtherPerson" "other@person.org" "commit 5" "${CMD[@]}"
CMD=(">> src/test1.cpp" ">> src/test3.cpp")
gen_commit ${PARENT_DIR}/repo3 "Third" "third@person.org" "commit 6" "${CMD[@]}"
CMD=(">> src/*.cpp")
gen_commit ${PARENT_DIR}/repo2 "John Doe" "john@doe.org"  "commit 7" "${CMD[@]}"
CMD=("mkdir -p src/p1" "touch src/p1/test1.cpp" "touch src/p1/test1.cpp")
gen_commit ${PARENT_DIR}/repo3 "OtherPerson" "other@person.org"  "commit 8" "${CMD[@]}"
CMD=(">> include/*.hpp")

# Add submodule to repo 1
mkdir -p ${PARENT_DIR}/repo1/src/submod1
cd ${PARENT_DIR}/repo1/src/submod1
git init
CMD=("touch README.md" "touch Makefile")
gen_commit ${PARENT_DIR}/repo1/src/submod1 "John Doe" "john@doe.org" "init_commit" "${CMD[@]}"
CMD=("mkdir -p src/" "touch src/test1.cpp" "touch src/test2.cpp" "touch src/test3.cpp" "mkdir -p include/" "touch include/test1.hpp" "touch include/test2.hpp" "touch include/test3.hpp")
gen_commit ${PARENT_DIR}/repo1/src/submod1 "John Doe" "john@doe.org" "commit 2" "${CMD[@]}"
CMD=("git submodule add ./src/submod1/ src/submod1")
gen_commit ${PARENT_DIR}/repo1 "John Doe" "john@doe.org" "adding submodule" "${CMD[@]}"
CMD=(">> README.md" "touch LICENSE")
gen_commit ${PARENT_DIR}/repo1 "OtherPerson" "other@person.org" "commit 5" "${CMD[@]}"
CMD=("mkdir -p src/p1" "touch src/p1/test1.cpp" "touch src/p1/test1.cpp")
gen_commit ${PARENT_DIR}/repo1/src/submod1 "John Doe" "john@doe.org" "commit 3" "${CMD[@]}"
CMD=(">> README.md" ">> Dockerfile")
gen_commit ${PARENT_DIR}/repo1 "John Doe" "john@doe.org" "commit 7" "${CMD[@]}"

# Add a nested submodule to repo 1's submodule.
mkdir -p ${PARENT_DIR}/repo1/src/submod1/src/submod2
cd ${PARENT_DIR}/repo1/src/submod1/src/submod2
git init
CMD=("touch README.md" "touch Makefile")
gen_commit ${PARENT_DIR}/repo1/src/submod1/src/submod2 "John Doe" "john@doe.org" "init_commit" "${CMD[@]}"
CMD=("mkdir -p src/" "touch src/test1.cpp" "touch src/test2.cpp" "touch src/test3.cpp" "mkdir -p include/" "touch include/test1.hpp" "touch include/test2.hpp" "touch include/test3.hpp")
gen_commit ${PARENT_DIR}/repo1/src/submod1/src/submod2 "John Doe" "john@doe.org" "commit 2" "${CMD[@]}"
CMD=("git submodule add ./src/submod2/ src/submod2")
gen_commit ${PARENT_DIR}/repo1/src/submod1 "John Doe" "john@doe.org" "adding submodule" "${CMD[@]}"
CMD=(">> LICENSE")
gen_commit ${PARENT_DIR}/repo1 "John Doe" "john@doe.org" "adding subsubmodule" "${CMD[@]}"