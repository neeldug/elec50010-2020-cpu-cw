#!/usr/bin/env bash

# Generates all binaries from c-files, execute from test directory

cd c-files || return 1
for file in *.c; do
  TESTNAME=$(basename "$file" | cut -f 1 -d '.')
  make "$TESTNAME".asm.txt
  make "$TESTNAME".hex.txt
  make "$TESTNAME".ref.txt
  make "$TESTNAME".hex.data.txt
done

cd .. || return 1

# Trim final line
for file in data/*.txt; do
  sed -i '$d' "$file"
done
