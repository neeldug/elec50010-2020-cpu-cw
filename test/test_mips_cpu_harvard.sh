#!/usr/bin/env bash

set -eo pipefail

# Script to test MIPS CPU (Harvard Interface)

if [ -z "$2" ]
then
  ./test/dispatcher.sh "$1"
else
  ./test/dispatcher.sh "$1" "$2"
fi
#Run against dispatcher for parallelisation

