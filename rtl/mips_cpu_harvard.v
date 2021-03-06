module mips_cpu_harvard (
    input logic clk,
    reset,
    output logic active,
    output logic [31:0] register_v0,

    input logic clk_enable,

    output logic [31:0] instr_address,  //PC Next
    input  logic [31:0] instr_readdata,  //Data stored at address determined by PCnext

    output logic [31:0] data_address,  //ALU_result
    output logic data_write,  //Control signal Data memory write enable for data
    output logic data_read,  //Control signal to request a read from memory
    output logic [31:0] data_writedata,
    input logic [31:0] data_readdata
);

  logic
      memtoreg1,
      memtoreg2,
      branch,
      alusrc,
      regdst1,
      regdst2,
      regwrite,
      jump1,
      jump,
      zero,
      pcsrc,
      signextbitwiseop;

  logic [4:0] alucontrol;
  logic [2:0] loadcontrol;

  decoder control_path (
      .clk(clk),
      .op(instr_readdata[31:26]),
      .funct(instr_readdata[5:0]),
      .dest(instr_readdata[20:16]),
      .zero(zero),
      .memtoreg2(memtoreg2),
      .memtoreg1(memtoreg1),
      .data_write(data_write),
      .data_read(data_read),
      .pcsrc(pcsrc),
      .alusrc(alusrc),
      .regdst2(regdst2),
      .regdst1(regdst1),
      .signextbitwiseop(signextbitwiseop),
      .regwrite(regwrite),
      .jump1(jump1),
      .jump(jump),
      .alucontrol(alucontrol),
      .loadcontrol(loadcontrol)
  );

  datapath data_path (
      .clk(clk),
      .reset(reset),
      .clk_enable(clk_enable),
      .active(active),
      .memtoreg2(memtoreg2),
      .memtoreg1(memtoreg1),
      .alusrc(alusrc),
      .pcsrc(pcsrc),
      .regdst2(regdst2),
      .regdst1(regdst1),
      .signextbitwiseop(signextbitwiseop),
      .regwrite(regwrite),
      .jump1(jump1),
      .jump(jump),
      .alucontrol(alucontrol),
      .loadcontrol(loadcontrol),
      .zero(zero),
      .instr_address(instr_address),
      .instr_readdata(instr_readdata),
      .data_readdata(data_readdata),
      .data_address(data_address),
      .data_writedata(data_writedata),
      .register_v0(register_v0)
  );


endmodule
