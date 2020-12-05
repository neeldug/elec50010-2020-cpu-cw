#!/usr/bin/env bash

BASEDIR=$(dirname "$0")

for file in "$BASEDIR"/c-files/*.c; do
  ./"$BASEDIR"/assembly/generate.sh "$file"
done

cd c-files
for file in *.c; do
  TESTNAME=$(basename "$file" | cut -f 1 -d '.')
  make "$TESTNAME".hex.txt
done

mv *.hex.txt ../binary/
