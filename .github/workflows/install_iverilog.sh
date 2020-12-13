#!/usr/bin/env bash

curl -O ftp://ftp.icarus.com/pub/eda/verilog/v11/verilog-11.0.tar.gz
tar -zxvf verilog-11.0.tar.gz

( cd verilog-11.0
sh autoconf.sh
./configure
make
sudo make install )

rm -rf verilog-11.0*
