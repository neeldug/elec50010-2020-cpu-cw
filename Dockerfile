FROM ubuntu

RUN apt-get update
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get install -y gcc g++ bison flex build-essential  gcc-mipsel-linux-gnu qemu-user curl autoconf gperf wget
RUN curl -O ftp://ftp.icarus.com/pub/eda/verilog/v11/verilog-11.0.tar.gz
RUN tar -zxvf verilog-11.0.tar.gz
RUN cd verilog-11.0 && sh autoconf.sh && ./configure && make && make install
RUN rm -rf verilog-11.0*
RUN wget https://github.com/google/verible/releases/download/v0.0-807-g10e7c71/verible-v0.0-807-g10e7c71-Ubuntu-20.04-focal-x86_64.tar.gz
RUN tar -zxvf verible-v0.0-807-g10e7c71-Ubuntu-20.04-focal-x86_64.tar.gz
RUN mv verible-v0.0-807-g10e7c71/bin/* /usr/bin
RUN rm -rf verible-*
