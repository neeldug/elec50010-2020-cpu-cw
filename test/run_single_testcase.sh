#!/usr/bin/env bash

SOURCE="$1"
TESTCASE="$2"

VERILOGDIR="test/testbench-verilog/"

# Compilation
iverilog -Wall -g 2012 \
    -s tb_harvard \
    -o test/simulator/mips_cpu_harvard_tb_"$TESTCASE" \
    -P tb_harvard.INSTR_INIT_FILE=\"test/binary/"$TESTCASE".hex.txt\" \
    -P tb_harvard.DATA_INIT_FILE=\"test/data/"$TESTCASE".hex.data.txt\" \
    $VERILOGDIR"tb_harvard.v" $VERILOGDIR"data_mem.v" $VERILOGDIR"instruction_mem.v" "$SOURCE/*.v"

# Execution

set +e
./test/simulator/mips_cpu_harvard_tb_"$TESTCASE" >test/output/mips_cpu_harvard_tb_$"TESTCASE".stdout
# Capture exit code
