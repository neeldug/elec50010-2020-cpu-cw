module datapath (
    input logic clk,
    reset,
    clk_enable,
    stall,
    output logic active,
    input logic storeloop,
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
    output logic [31:0] register_v0

	//output logic [31:0] register_debug,				//debug (+ @regfile and in extrafunction.v)
	//output logic [31:0] srca, srcb					//debug
);


  // Instanciation of all wires required
  logic [4:0] writereg1, writereg;
  logic [31:0] pcnext, pcnextbr, pcrst, pcplus4, pcbranch, pclink, pcnextbrin, pcnextbrout;
  logic [31:0] signimm, signimmsh, immsh16, pcnextbr1, pcnextbr2, jumpsh;
  logic [31:0] result2, result1, result;
  logic [31:0] pcresult;
  assign stall = 0; //temp
  								
  logic [31:0] rda, reg32;
  logic [31:0] resultregfile, resultstore;
  logic [31:0] srca, srcb;							//non-debug






  // --------------  Delay Slot Implementation  ------------

  logic [31:0] pcnext_delay;

  // Flip-flop to save the adress to go to in the next cycle
  regfile1 #(32) jumpbrmem (
      .clk(clk),
      .reset(reset),
      .clk_enable(clk_enable),
      .stall(stall),
      .d(pcnext),
      .q(pcnext_delay)
  );

  logic [31:0] pcplus4delay;

  // PC_delay+4
  adder pcpl4_delay (
      .a(pcnext_delay),
      .b(32'b100),
      .y(pcplus4delay)
  );
  
  logic [31:0] pcbranch_pcplus4delay;
  
  // MUX to select either normal PC+4 or address from branch instr.
  mux2 #(32) pcmux3 (
      .a(pcplus4delay),
      .b(pcbranch),
      .s(pcsrc),
      .y(pcbranch_pcplus4delay)
  );  // note: pcsrc is high when we are in a branch instruction and the condition (zero flag) are met.


  //  ---------------  Program Counter Datapath  --------------

  // Program Counter register
  flipflopr #(32) pcreg (
      .clk(clk),
      .reset(reset),
      .clk_enable(clk_enable),
      .stall(stall),
      .active(active),
      .d(pcnext_delay),
      .q(instr_address)
  );

  // Info: we read the instruction at the address of the Program Counter 

  // PC+4
  adder pcpl4 (
      .a(instr_address),
      .b(32'b100),
      .y(pcplus4)
  );

  //  Sign-extend the immediate from the instr.
  signext se (
      .a(instr_readdata[15:0]),
      .y(signimm)
  );

  // Double shift left of the sign-extended immediate (branch instr.)
  shiftleft2 immshift (
      .a(signimm),
      .y(signimmsh)
  );

  // PC-branch (PC+4 + offset from the immediate of the branch instr.)
  adder pcbr (
      .a(signimmsh),
      .b(pcplus4),
      .y(pcbranch)
  );




  // --------------  Jump-to-PC Datapath ------------

  logic [31:0] jumpregsh;
  logic [31:0] jump_address_sh, jumpreg_address, next_jump_address;

  // Double shift left of jump address from instr. (j/jal)
  shiftleft2 jsh (
      .a({6'b0, instr_readdata[25:0]}),
      .y(jump_address_sh)
  );
  
  assign jumpreg_address = result2;	// note: the result of the ALU is the address we need to jump to
  
  // MUX to select either address from data of regular jump instr. (j/jal) or address from register of jump register instr. (jr/jalr)
  mux2 #(32) pcmux1 (
      .a({pcplus4[31:28], jump_address_sh[27:0]}),
      .b(jumpreg_address),
      .s(jump1),
      .y(next_jump_address)
  );  //note: jump1 is high when we jump to value in register.
  
  // MUX to select either (PC+4 || PC from branch instr.) or (Address from data of j/jal || Address from register of jr/jalr)
  mux2 #(32) pcmux2 (
      .a(pcbranch_pcplus4delay),
      .b(next_jump_address),
      .s(jump),
      .y(pcnext)		//note: this goes inside the delay_slot block
  );  // note: jump is high when we are in a jump instruction.






  //  ------------------  Register file Datapath  ---------------------

  //Register file module
  regfile register (
      .clk(clk),
      .reset(reset),
      .we3(regwrite),
      .ra1(instr_readdata[25:21]),
      .ra2(instr_readdata[20:16]),
      .wa3(writereg),
      .wd3(resultregfile),
      .rd1(rda),
      .rd2(data_writedata),
      .reg_v0(register_v0)//
      //.reg_debug(register_debug)							//debug (+ in extrafunction.v)
  );
  
  
  // Register file used for merging data in Registers and in Data memory in Store instructions (SB and SH).
  regfile2 #(32) register32 (
  	  .clk(clk),
  	  .reset(reset),
  	  .we(storeloop),
  	  .d(resultstore),
  	  .q(reg32)
  ); // Write enable, WE: storeloop, is high during Store instructions.
  
  // MUX for alu input selection in store instructions [stage 2: merging byte(s) stored and initial value in RAM]. 
  mux2 #(32) srcaslct (
      .a(rda),
      .b(reg32),
      .s(storeloop),
      .y(srca)
  ); // note: storeloop is high for SB and SH instructions only.
  
  
  // DEMUX for implementation of the Store instructions.
  demux2 #(32) wdchoice (
  	  .a(result),
  	  .s(storeloop),
  	  .y1(resultregfile),
  	  .y2(resultstore)
  ); // note: storeloop is high for SB and SH instructions only.

 
  // MUX to select which part of the instr. is the destination register.
  mux2 #(5) wrmux (
      .a(instr_readdata[20:16]),
      .b(instr_readdata[15:11]),
      .s(regdst1),
      .y(writereg1)
  );  // note: regdst1 is high for R-type instructions else select I-type.
  
  
  //  MUX to select either register address from instr. or register $31 (for jr/jalr)
  mux2 #(5) wrmux2 (
      .a(writereg1),
      .b(5'b11111),
      .s(regdst2),
      .y(writereg)
  );  // note: regdst2 is high for link instructions (store value in $31).



  //  --------------- Out-of-Memory Datapath -------------------

  // Load Selector module
  loadselector loadsel (
      .a(data_readdata),
      .controls(loadcontrol),
      .y(result1)
  );

  // MUX to select either result from ALU or from Memory
  mux2 #(32) resmux (
      data_address, // note: this is the output of the ALU
      result1,
      memtoreg1,
      result2
  );  // note: memtoreg1 is high for load instructions (value in RAM) else take result from ALU.
  
  
  // PC+8 for link address to be stored in reg$31
  adder pcbrlink (
      .a(pcplus4),
      .b(32'b100),
      .y(pclink)
  );
  
  // MUX to select either the result from ALU/Memory or the link address to be stored in the register file
  mux2 #(32) resmux2 (
      result2,
      pclink,
      memtoreg2,
      result
  );  // note: memtoreg2 is high for Branch with condition met and Jump with link instructions.





  //  -------------------  ALU Datapath  -------------------

  // MUX to select either data from register or from immediate as SRCb of ALU
  mux2 #(32) srcbmux (
      data_writedata,
      signimm,
      alusrc,
      srcb
  );  // note: alusrc is high for instructions using Immediate variable else for srcB instr.

  // ALU Module
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










  /*			SAVE of jump datapath
  mux2 #(32) pcmux1 (
      .a({6'b0, instr_readdata[25:0]}),
      .b(result2),
      .s(jump1),
      .y(pcnextbr2)
  );  // jump1 is high when we jump to value in register.

  shiftleft2 jsh (
      .a(pcnextbr2),
      .y(jumpsh)
  );  // Instruction in PC are every 4 so we need to multiply by 4.
  */
