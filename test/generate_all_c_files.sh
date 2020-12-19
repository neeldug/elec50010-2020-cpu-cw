#!/usr/bin/env bash

# Generates all binaries from c-files, execute from test directory

c_gen() {
  local file=$1
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
}

cd c-files || return 1
for file in *.c; do
  c_gen "$file" &
done

asm_gen() {
  local file=$1
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
  if [ ! -f ../reference/"$TESTNAME".ref.txt ]; then
    make "$TESTNAME".ref.txt
  fi
}

cd ../raw-assembly || return 1
for file in *.s; do
  asm_gen "$file" &
done

wait
