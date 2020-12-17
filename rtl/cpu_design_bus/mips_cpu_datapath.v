module datapath (
    input logic clk,
    reset,
//    clk_enable,
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
    output logic [31:0] address,
    input logic [31:0] readdata,
    output logic [31:0] writedata,
    output logic [31:0] register_v0, register_v3,
    output logic pcsrclast
);

//to add in definition of module's entities.

  input logic [1:0] alusrcb,
  input logic alusrca,
  input logic irwrite, iord,
  logic [31:0] pcnext, pcout, instr, data, aluresult, aluout;
  logic [31:0] rd1, rd2, rega, regb;
  
//end 

  logic [4:0] writereg1, writereg;
  logic [31:0] pcnext, pcnextbr, pcrst, pcplus4, pcbranch, pclink, pcnextbrin, pcnextbrout;
  logic [31:0] signimm, signimmsh, pcnextbr1, pcnextbr2, jumpsh;
  logic [31:0] srca, srcb;
  logic [31:0] result2, result1, result;
  logic [31:0] pcresult;
//  logic pcsrclast;
  
/*
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
  	  .we(1'b1),	//change control signal as now takes more than 1 clk cycle maybe @(writereg).
  	  .d(pcsrc),
  	  .q(pcsrclast)
  );
*/
 
/*  mux2 #(32) pcmux (
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
*/

// Program counter regfile

/*

  mux2 #(32) pcmux1 (
      .a({6'b0, instr[25:0]}),
      .b(pcnext),
      .s(jump1),
      .y(pcnextbr2)
  );  //jump1 is high when we jump to value in register.

  jumpsl2 jsh (
      .a(pcnextbr2),
      .control(jump),
      .y(pcnextbrin)
  );  //Instruction in PC are every 4 so we need to multiply by 4 when it is jump.


  mux2 #(32) pcmux2bis (
      .a(pcbranch),
      .b(jumpsh),
      .s(jump), //jump
      .y(pcnextbrin)
  );  //jump is high when we are in a jump instruction.

  mux2 #(32) pcmux2 (
      .a(pcnext),
      .b(pcnextbrout),
      .s(pcsrclast), //pcsrc
      .y(pcnextbr1)
  );  //pcsrc is high when we are in a branch instruction and the condition. (zero flag) are met.

  mux2 #(32) pcmux (
  	  .a(pcnextbr1),
      .b(pcplus4),
      .s(memtoreg2), 
      .y(pcnextbr)
  );
*/ 
  
    
  mux2 #(32) PCsrc (
  	  .a(aluresult),
  	  .b(aluout),
  	  .s(pcsrc),
  	  .y(pcnext)
  );
  
  
  regfile1 #(31) pcreg (
	  .clk(clk),
	  .reset(reset),
	  .we(pcen),
	  .d(pcnext),
	  .q(pcout)
  );
  

  mux2 #(32) addrsel(
	  .a(pcout),
	  .b(aluout),
	  .s(iord),
	  .y(address)
  );
  
// INstruction and Data registers
  regfile1 #(31) ir (
	  .clk(clk),
	  .reset(reset),
	  .we(irwrite),
	  .d(readdata),
	  .q(instr)
  );
  
  regfile1 #(31) datareg (
	  .clk(clk),
	  .reset(reset),
	  .we(1'b1),
	  .d(readdata),
	  .q(data)
  );

// Register module  
  signext se (
      .a(instr[15:0]),
      .y(signimm)
  );

  shiftleft2 immshift (  //used for branch implementation.
      .a(signimm),
      .y(signimmsh)
  );



  // Register file

  //we added an output: register_v0 so that this value is accessible from the outside of the Mips_cpu at all time.
  regfile register (
      .clk(clk),
      .reset(reset),
      .we3(regwrite),
      .ra1(instr[25:21]),
      .ra2(instr[20:16]),
      .wa3(writereg),
      .wd3(result),
      .rd1(rd1),
      .rd2(rd2),
      .reg_v0(register_v0),
      .reg_v3(register_v3)
  );
  
  regfile1 #(31) regdst1 (
	  .clk(clk),
	  .reset(reset),
	  .we(1'b1),
	  .d(rd1),
	  .q(rega)
  );
  
  regfile1 #(31) regdst2 (
	  .clk(clk),
	  .reset(reset),
	  .we(1'b1),
	  .d(rd2),
	  .q(regb)
  );
  
  mux2 #(5) wrmux (
      .a(instr[20:16]),
      .b(instr[15:11]),
      .s(regdst1),
      .y(writereg1)
  );  //regdst1 is high for R-type instructions else select I-type.
  
  mux2 #(5) wrmux2 (
      .a(writereg1),
      .b(5'b11111),
      .s(regdst2),
      .y(writereg)
  );  //regdst2 is high for link instructions (store value in $31).


  loadselector loadsel (
      .a(data), //data_readadta
      .controls(loadcontrol),
      .y(result1)
  );

  //Result--value written in register (Load/Branches/Jump)
  mux2 #(32) resmux (
      aluout,
      result1,
      memtoreg1,
      result
  );  //memtoreg1 is high for load instructions (value in RAM) else take result from ALU.

/*  mux2 #(32) resmux2 (
      result2,
      pclink,
      memtoreg2,
      result
  );  //memtoreg2 is high for Branch with condition met and Jump with link instructions.  */ 
  
// We won't need that as we can use another adder and will have to use ALU.




// ALU file input selectors:
  mux4 #(32) srcbmux (
      .a(regb),			//register value		00
      .b(32'b100),  	//PC + 4				01
      .c(signimm),  	//Immediate variable 	10
      .d(signimmsh),	//Branch instr			11
      .s(alusrcb),
      .y(srcb)
  ); 
  
  mux2 #(32) srcamux (
  	  .a(pcout),		//PC for Branch			0
  	  .b(rega),			//register value		1
  	  .s(alusrca),
  	  .y(srca)
  );

  alu alumodule (
      .reset(reset),
      .control(alucontrol),
      .a(srca),
      .b(srcb),
      .shamt(instr[10:6]),
      .zero(zero),
      .y(aluresult)
  );
  
  regfile1 #(31) alureg (
	  .clk(clk),
	  .reset(reset),
	  .we(1'b1),
	  .d(aluresult),
	  .q(aluout)
  );
endmodule
