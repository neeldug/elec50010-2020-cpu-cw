#!/usr/bin/env bash

SOURCE="$1"
TESTCASE="$2"
INSTR="$3"

list=$(find "$SOURCE" -type f -name '*.v')

VERILOGDIR="test/testbench-verilog/"
# Compilation
iverilog -Wall -g 2012 \
    -s tb_harvard \
    -o test/simulator/mips_cpu_harvard_tb_"$TESTCASE" \
    -P tb_harvard.INSTR_INIT_FILE=\"test/binary/"$TESTCASE".hex.txt\" \
    -P tb_harvard.DATA_INIT_FILE=\"test/data/"$TESTCASE".hex.data.txt\" \
    $VERILOGDIR"tb_harvard.v" $VERILOGDIR"data_mem.v" $VERILOGDIR"instruction_mem.v" "$list"

# Execution

set +e
./test/simulator/mips_cpu_harvard_tb_"$TESTCASE" >test/output/mips_cpu_harvard_tb_"$TESTCASE".stdout
# Capture exit code

RESULT=$?
set -e

#Checks if simulation returned an error code (e.g. cpu failed to hault)
if [[ "${RESULT}" -ne 0 ]] ; then
   echo "${TESTCASE}, ${INSTR}, Fail"
   exit
fi

#Compare output to reference
set +e
diff -w test/reference/"${TESTCASE}".ref.txt test/output/mips_cpu_harvard_tb_"$TESTCASE".stdout &>/dev/null
RESULT=$?
set -e

#Determine outcome based on result of comparison
if [[ "${RESULT}" -ne 0 ]] ; then
   echo "${TESTCASE}, ${INSTR}, Fail"
else
   echo "${TESTCASE}, ${INSTR}, Pass"
fi
