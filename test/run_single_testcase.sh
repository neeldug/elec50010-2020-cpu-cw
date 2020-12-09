#!/usr/bin/env bash

SOURCE=$1
TESTCASE=$2

# Do some icarus-verilog compilation here using the binary testcase for memory and compile using verilog from $SOURCE :)

iverilog -Wall -g 2012 \
    testbench-verilog/tb_harvard testbench-verilog/data_mem.v testbench0verilog/instruction_mem.v ${SOURCE}/*.v \
    -s testbench-verilog/tb_harvard \
    -P tb_harvard.INSTR_INIT_FILE="test/binary/${TESTCASE}.hex.txt" \
    -o simulator/mips_cpu_harvard_tb_${TESTCASE}
