module datapath (
    input logic clk,
    reset,
    clk_enable,
    input logic memtoreg2,
    memtoreg1,
    input logic alusrc,
    pcsrc,
    input logic regdst2,
    regdst1,
    input logic regwrite,
    input logic jump1,
    jump,
    input logic [4:0] alucontrol,
    input logic [2:0] loadcontrol,
    output logic zero,
    output logic [31:0] instr_address,
    input logic [31:0] instr_readdata,
    input logic [31:0] data_readdata,
    output logic [31:0] data_address,
    data_writedata,
    output logic [31:0] register_v0,
    register_v3,
    output logic pcsrclast,

    output logic [31:0] srca,
    srcb  //DEBUGGING
);


  logic [4:0] writereg1, writereg;
  logic [31:0] pcnext, pcnextbr, pcrst, pcplus4, pcbranch, pclink, pcnextbrin, pcnextbrout;
  logic [31:0] signimm, signimmsh, immsh16, pcnextbr1, pcnextbr2, jumpsh;
  //logic [31:0] srca, srcb;
  logic [31:0] result2, result1, result;
  logic [31:0] pcresult;
  //  logic pcsrclast;



  // Program counter regfile

  regfile1 #(31) jumpbrmem (
      .clk(clk),
      .reset(reset),
      .we(memtoreg2),
      .d(pcnextbrin),
      .q(pcnextbrout)
  );

  regfile2 #(0) pcsrcreg (
      .clk(clk),
      .reset(reset),
      .we(1'b1),
      .d(pcsrc),
      .q(pcsrclast)
  );

  mux2 #(32) pcmux (
      .a(pcnextbr1),
      .b(pcplus4),
      .s(memtoreg2),
      .y(pcnextbr)
  );

  flipflopr #(32) pcreg (
      .clk(clk),
      .reset(reset),
      .clk_enable(clk_enable),
      .d(pcnextbr),
      .q(instr_address)
  );


  adder pcpl4 (
      .a(instr_address),
      .b(32'b100),
      .y(pcplus4)
  );

  signext se (
      .a(instr_readdata[15:0]),
      .y(signimm)
  );

  shiftleft2 immshift (
      .a(signimm),
      .y(signimmsh)
  );

  adder pcbr (
      .a(signimmsh),
      .b(pcplus4),
      .y(pcbranch)
  );

  mux2 #(32) pcmux3 (
      .a(pcplus4),
      .b(pcnextbrout),
      .s(pcsrclast),  //pcsrc
      .y(pcnextbr1)
  );  //pcsrc is high when we are in a branch instruction and the condition. (zero flag) are met.




  // --------------  Jump  ------------

  logic [31:0] jumpregsh;

  mux2 #(32) pcmux1 (
      .a({pcplus4[31:28], jumpsh[27:0]}),
      .b(jumpregsh),
      .s(jump1),
      .y(pcnextbr2)
  );  //jump1 is high when we jump to value in register.

  shiftleft2 jsh (
      .a({6'b0, instr_readdata[25:0]}),
      .y(jumpsh)
  );  //Instruction in PC are every 4 so we need to multiply by 4.

  shiftleft2 jsh2 (
      .a(result2),
      .y(jumpregsh)
  );  //Instruction in PC are every 4 so we need to multiply by 4.


  /*			SAVE	
  mux2 #(32) pcmux1 (
      .a({6'b0, instr_readdata[25:0]}),
      .b(result2),
      .s(jump1),
      .y(pcnextbr2)
  );  //jump1 is high when we jump to value in register.

  shiftleft2 jsh (
      .a(pcnextbr2),
      .y(jumpsh)
  );  //Instruction in PC are every 4 so we need to multiply by 4.
  */


  mux2 #(32) pcmux2 (
      .a(pcbranch),
      .b(pcnextbr2),  //jumpsh
      .s(jump),  //jump
      .y(pcnextbrin)
  );  //jump is high when we are in a jump instruction.




  // ------------------  Register file  ---------------------

  //we added an output: register_v0 so that this value is accessible from the outside of the Mips_cpu at all time.
  regfile register (
      .clk(clk),
      .reset(reset),
      .we3(regwrite),
      .ra1(instr_readdata[25:21]),
      .ra2(instr_readdata[20:16]),
      .wa3(writereg),
      .wd3(result),
      .rd1(srca),
      .rd2(data_writedata),
      .reg_v0(register_v0),
      .reg_v3(register_v3)
  );

  mux2 #(5) wrmux (
      .a(instr_readdata[20:16]),
      .b(instr_readdata[15:11]),
      .s(regdst1),
      .y(writereg1)
  );  //regdst1 is high for R-type instructions else select I-type.

  mux2 #(5) wrmux2 (
      .a(writereg1),
      .b(5'b11111),
      .s(regdst2),
      .y(writereg)
  );  //regdst2 is high for link instructions (store value in $31).

  adder pcbrlink (
      .a(pcplus4),
      .b(32'b100),
      .y(pclink)
  );

  //Load selector bit (word/byte/LSB...)
  shiftleft16 immshift16 (
      .a({16'b0, instr_readdata[15:0]}),
      .y(immsh16)
  );  //extended the instr_readdata to fit declaration of shiftleft16

  loadselector loadsel (
      .a(data_readdata),  //data_readadta
      .controls(loadcontrol),
      .y(result1)
  );

  //Result--value written in register (Load/Branches/Jump)
  mux2 #(32) resmux (
      data_address,
      result1,
      memtoreg1,
      result2
  );  //memtoreg1 is high for load instructions (value in RAM) else take result from ALU.
  mux2 #(32) resmux2 (
      result2,
      pclink,
      memtoreg2,
      result
  );  //memtoreg2 is high for Branch with condition met and Jump with link instructions.

  //ALU file
  mux2 #(32) srcbmux (
      data_writedata,
      signimm,
      alusrc,
      srcb
  );  //alusrc is high for instructions using Immediate variable else for srcB instr.

  alu alumodule (
      .reset(reset),
      .control(alucontrol),
      .a(srca),
      .b(srcb),
      .shamt(instr_readdata[10:6]),
      .zero(zero),
      .y(data_address)
  );

endmodule
