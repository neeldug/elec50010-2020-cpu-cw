FROM ubuntu

RUN apt-get update
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get install -y gcc g++ bison flex build-essential  gcc-mipsel-linux-gnu qemu-user curl autoconf gperf
RUN curl -O ftp://ftp.icarus.com/pub/eda/verilog/v11/verilog-11.0.tar.gz
RUN tar -zxvf verilog-11.0.tar.gz
RUN cd verilog-11.0 && sh autoconf.sh && ./configure && make && make install
RUN rm -rf verilog-11.0*
