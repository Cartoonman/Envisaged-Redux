#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

mkdir ${DIR}/test_wkdir
cd ${DIR}/test_wkdir
mkdir repo1
mkdir repo2
mkdir repo3
cd ${DIR}/test_wkdir/repo1
git init
cd ${DIR}/test_wkdir/repo2
git init
cd ${DIR}/test_wkdir/repo3
git init
RANDOM=1341
TS=1358795000
# R1 C1
cd ${DIR}/test_wkdir/repo1
git config user.name "John Doe"
git config user.email "john@doe.org"
touch README.md
touch Makefile
export GIT_AUTHOR_DATE="$TS -0000"
export GIT_COMMITTER_DATE="$TS +0000"
git add .
git commit -m "init_commit"
TS=$(( $TS+$RANDOM+$RANDOM ))
# R1 C2
cd ${DIR}/test_wkdir/repo1
git config user.name "John Doe"
git config user.email "john@doe.org"
touch test.cpp
mkdir -p proj/src
touch proj/src/test2.cpp
echo "000" > README.md
export GIT_AUTHOR_DATE="$TS -0000"
export GIT_COMMITTER_DATE="$TS +0000"
git add .
git commit -m "commit 2"
TS=$(( $TS+$RANDOM+$RANDOM ))

