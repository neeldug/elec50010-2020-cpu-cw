#!/usr/bin/env bash

set -eo pipefail

# Script to test MIPS CPU (Harvard Interface)

if [ -z "$2" ]
then
  ./test/dispatcher.sh "$1" | xargs -L1 -P4 ./test/run_single_testcase.sh
else
  ./test/dispatcher.sh "$1" "$2" | xargs -L1 -P4 ./test/run_single_testcase.sh
fi
#Run against dispatcher for parallelisation

