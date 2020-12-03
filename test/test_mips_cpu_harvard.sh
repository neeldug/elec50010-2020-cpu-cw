#!/usr/bin/env bash
# Script to test MIPS CPU (Harvard Interface)

# Declare args as vars
SOURCE=$1
ALL=false

# Optional second arg, handling all cases.
if [ -n "$2" ]
then
  INSTR=$2
else
  ALL=true
fi

if [ "$ALL" = true ]
then
  TESTCASES="test/assembly/*.asm.txt"
else
  TESTCASES="test/assembly/$INSTR*.asm.txt"
fi

for i in ${TESTCASES} ; do
  TESTNAME=$(basename "$i" | cut -f 1 -d '.')
  #Dispatch to single scripts here
  ./test/run_single_testcase.sh "$SOURCE" "$TESTNAME"
done
