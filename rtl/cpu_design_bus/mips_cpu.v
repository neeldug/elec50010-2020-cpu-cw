module CPU_MIPS_bus (
    input logic clk,
    reset,
    output logic active,
    output logic [31:0] register_v0,

    output logic [31:0] address,  //Memory addressing
    output logic write,
    output logic read,
    input logic waitrequest,
    output logic [31:0] writedata,
    output logic [3:0] byteenable,
    input logic [31:0] readdata,
);

  logic memtoreg1, memtoreg2, branch, alusrc, regdst1, regdst2, regwrite, jump1, jump, zero, pcsrc;

  logic [4:0] alucontrol;
  logic [2:0] loadcontrol;

  controller control (
      .op(instr_readdata[31:26]),
      .funct(instr_readdata[5:0]),
      .dest(instr_readdata[20:16]),
      .zero(zero),
      .memtoreg2(memtoreg2),
      .memtoreg1(memtoreg1),
      .data_write(data_write),
      .pcsrc(pcsrc),
      .alusrc(alusrc),
      .regdst2(regdst2),
      .regdst1(regdst1),
      .regwrite(regwrite),
      .jump1(jump1),
      .jump(jump),
      .alucontrol(alucontrol),
      .loadcontrol(loadcontrol)
  );

  datapath datap (
      .clk(clk),
      .reset(reset),
      .alusrc(alusrc),
      .pcsrc(pcsrc),
      .regdst2(regdst2),
      .regdst1(regdst1),
      .regwrite(regwrite),
      .jump1(jump1),
      .jump(jump),
      .alucontrol(alucontrol),
      .loadcontrol(loadcontrol),
      .zero(zero),
      .address(address),
      .readdata(readdata),
      .writedata(writedata),
      .register_v0(register_v0)
  );
  
  assign active = (instr_address==32'b0) ? 0 : 1; //If PC counter points to address 0, then the CPU is halted

endmodule
