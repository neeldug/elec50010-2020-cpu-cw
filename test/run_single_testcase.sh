#!/usr/bin/env bash

SOURCE=$1
TESTCASE=$2

VERILOGDIR="test/testbench-verilog/"

# Do some icarus-verilog compilation here using the binary testcase for memory and compile using verilog from $SOURCE :)

iverilog -Wall -g 2012 \
    -s tb_harvard \
    $VERILOGDIR"tb_harvard.v" $VERILOGDIR"data_mem.v" $VERILOGDIR"instruction_mem.v" ${SOURCE}/*.v \
    -P tb_harvard.INSTR_INIT_FILE="test/binary/${TESTCASE}.hex.txt" \
    -o simulator/mips_cpu_harvard_tb_${TESTCASE}
