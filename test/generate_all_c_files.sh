#!/usr/bin/env bash

BASEDIR=$(dirname "$0")

for file in "$BASEDIR"/c-files/*; do
  ./"$BASEDIR"/assembly/generate.sh "$file"
done
