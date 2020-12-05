#!/usr/bin/env bash

BASEDIR=$(dirname "$0")

mips-linux-gnu-gcc -S -EB -mfp32 -O3 -march=mips1 "$1" -o "$BASEDIR""/"$(basename "$1" .c).asm.txt
