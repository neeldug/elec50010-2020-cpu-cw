#!/usr/bin/env bash

# Declare args as vars
SOURCE=$1
ALL=false

# Verify first arg passed
if [ -z "$1" ]
then
  echo "Source argument not present, unable to run!" 1>&2
  exit 64
fi
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
  echo "$1" "$TESTNAME"
done
