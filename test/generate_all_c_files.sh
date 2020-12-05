#!/usr/bin/env bash

# Generates all binaries from c-files, execute from test directory

cd c-files
for file in *.c; do
  TESTNAME=$(basename "$file" | cut -f 1 -d '.')
  make "$TESTNAME".hex.txt
done
