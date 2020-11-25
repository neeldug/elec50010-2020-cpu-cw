#!/usr/bin/env bash

for file in c-files/*; do
  ./assembly/generate.sh "$file"
done
