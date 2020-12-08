#!/usr/bin/env bash

set -eo pipefail

# Script to test MIPS CPU (Harvard Interface)

#Run against dispatcher for parallelisation
./test/dispatcher.sh "$1" "$2" | xargs -0 -P4 ./test/run_single_testcase.sh
