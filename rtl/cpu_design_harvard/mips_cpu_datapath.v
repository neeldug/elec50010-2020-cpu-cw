module datapath (
    input logic clk,
    reset,
    clk_enable,
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
    output logic [31:0] register_v0,

	output logic [31:0] register_debug,				//debug (+ @regfile and in extrafunction.v)
	output logic [31:0] srca, srcb					//debug
);


  // Instanciation of all wires required
  logic [4:0] writereg1, writereg;
  logic [31:0] pcnext, pcnextbr, pcrst, pcplus4, pcbranch, pclink, pcnextbrin, pcnextbrout;
  logic [31:0] signimm, signimmsh, immsh16, pcnextbr1, pcnextbr2, jumpsh;
  logic [31:0] result2, result1, result;
  logic [31:0] pcresult;
  								
//  logic [31:0] srca, srcb;							//non-debug

  logic stall;
  logic [31:0] instr_data; // note: either instr_readdata (from instr. mem.) or the instr. from the SB/SH scheduler





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


  // SB and SH scheduler block
  logic mux_stage2, mux_stage3, parallel_path;

  sb_sh_scheduler scheduler(
      //inputs
      .clk(clk),
      .clk_enable(clk_enable),
      .reset(reset),
      .normal_instr_data(instr_readdata),
      //outputs
      .stall(stall),
      .parallel_path(parallel_path),
      .mux_stage2(mux_stage2),
      .mux_stage3(mux_stage3),
      .normal_or_scheduled_instr_data(instr_data)

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
      .a(instr_data[15:0]),
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
      .a({6'b0, instr_data[25:0]}),
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

  logic [31:0] rda, rdb, reg32; //outputs of registers
  logic [31:0] result_regfile, result_parallel; //inputs to register
  logic [4:0] result_address;


  //Register file module
  regfile register (
      .clk(clk),
      .reset(reset),
      .we3(regwrite),
      .ra1(instr_data[25:21]),
      .ra2(instr_data[20:16]),
      .wa3(result_address),
      .wd3(result_regfile),
      .rd1(rda),
      .rd2(rdb),
      .reg_v0(register_v0),
      .reg_debug(register_debug)							//debug (+ in extrafunction.v)
  );

  // DEMUX for implementation of the Store instructions.
  demux2 wdchoice (
  	  .data(result),
  	  .address(writereg),
  	  .s(parallel_path),
  	  .normal_out(result_regfile),
  	  .parallel_out(result_parallel),
  	  .address_out(result_address)
  ); // note: parallel_path is high for SB and SH instructions only.
  
  // Register file used for merging data in Registers and in Data memory in Store instructions (SB and SH).
  regfile2 #(32) register32 (
  	  .clk(clk),
  	  .reset(reset),
  	  .we(parallel_path),
  	  .wd(result_parallel),
  	  .rd(reg32)
  ); // Write enable, WE: storeloop, is high during Store instructions.
  
  // MUX for alu input selection in store instructions [stage 2: merging byte(s) stored and initial value in RAM]. 
  mux2 #(32) srca_select (
      .a(rda),
      .b(reg32),
      .s(1),
      .y(srca)
  ); // note: mux_stage2 is high for SB and SH instructions when we need to use the ALU.
  
    // MUX for alu input selection in store instructions [stage 3: storing back in RAM]. 
  mux2 #(32) srcb_select (
      .a(rdb),
      .b(reg32),
      .s(1),
      .y(data_writedata)
  ); // note: mux_stage3 is high for SB and SH instructions when we need to write back to memory.
  





  // MUX to select which part of the instr. is the destination register.
  mux2 #(5) wrmux (
      .a(instr_data[20:16]),
      .b(instr_data[15:11]),
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
      .shamt(instr_data[10:6]),
      .zero(zero),
      .y(data_address)
  );

endmodule
