#!/usr/bin/env bash

# Generates all binaries from c-files, execute from test directory

cd c-files || return 1
for file in *.c; do
  TESTNAME=$(basename "$file" | cut -f 1 -d '.')
  if [ ! -f  ../assembly/"$TESTNAME".asm.txt ]; then
    make "$TESTNAME".asm.txt
  fi
  if [ ! -f ../binary/"$TESTNAME".hex.txt ]; then
    make "$TESTNAME".hex.txt
  fi
  if [ ! -f ../reference/"$TESTNAME".ref.txt ]; then
    make "$TESTNAME".ref.txt
  fi
  if [ ! -f ../data/"$TESTNAME".hex.data.txt ]; then
    make "$TESTNAME".hex.data.txt
  fi
done

cd ../raw-assembly || return 1
for file in *.s; do
  TESTNAME=$(basename "$file" | cut -f 1 -d '.')
  if [ ! -f  ../assembly/"$TESTNAME".asm.txt ]; then
    make "$TESTNAME".asm.txt
  fi
  if [ ! -f ../binary/"$TESTNAME".hex.txt ]; then
    make "$TESTNAME".hex.txt
  fi
  if [ ! -f ../data/"$TESTNAME".hex.data.txt ]; then
    make "$TESTNAME".hex.data.txt
  fi
done
