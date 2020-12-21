module decoder (
    input logic clk,
    input logic [5:0] op,
    funct,
    input logic [4:0] dest,
    input logic zero,
    output logic memtoreg2,
    memtoreg1,
    output logic data_write,
    output logic data_read,
    output logic pcsrc,
    alusrc,
    output logic regdst2,
    regdst1,
    output logic signextbitwiseop,
    output logic regwrite,
    output logic jump1,
    jump,
    output logic [4:0] alucontrol,
    output logic [2:0] loadcontrol
);

  logic [1:0] aluop, state;
  logic branch;

  main_decoder maindec (
      .clk(clk),
      .op(op),
      .funct(funct),
      .dest(dest),
      .memtoreg1(memtoreg1),
      .data_write(data_write),
      .data_read(data_read),
      .branch(branch),
      .alusrc(alusrc),
      .regdst2(regdst2),
      .regdst1(regdst1),
      .signextbitwiseop(signextbitwiseop),
      .regwrite(regwrite),
      .jump1(jump1),
      .jump(jump),
      .state(state),
      .aluop(aluop),
      .loadcontrol(loadcontrol)
  );

  alu_decoder aludec (
      .funct(funct),
      .op(op),
      .state(state),
      .dest(dest),
      .aluop(aluop),
      .alucontrol(alucontrol)
  );

  always_comb begin
    pcsrc = (branch && zero);
    memtoreg2 = (jump || pcsrc);
  end

endmodule
