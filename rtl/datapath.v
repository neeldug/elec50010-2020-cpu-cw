module datapath(
	input logic clk, reset, clk_enable,
	input logic memtoreg2, memtoreg1,
	input logic alusrc, pcsrc,
	input logic regdst2, regdst1,
	input logic regwrite,
	input logic jump1, jump,
	input logic [4:0] alucontrol,
	input logic [2:0] loadcontrol,
	output logic zero,
	output logic [31:0] instr_address,
	input logic [31:0] instr_readdata,
	input logic [31:0] data_readdata,
	output logic [31:0] data_address, data_writedata,
	output logic [31:0] register_v0);


logic [4:0] writereg1, writereg;
logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch, pclink;
logic [31:0] signimm, signimmsh, pcnextbr1, pcnextbr2, jumpsh;
logic [31:0] srca, srcb;
logic [31:0] result2, result1, result;



// Program counter regfile
flipflopr #(32) pcreg(clk, reset, clk_enable, pcnextbr, instr_address);

adder pcpl4(instr_address, 32'b100, pcplus4);

signext se(instr_readdata[15:0], signimm); 

shiftleft2 immshift(signimm, signimmsh);

adder pcbr(signimmsh, pcplus4, pcbranch);

mux2 #(32) pcmux1(pcplus4, pcbranch, pcsrc, pcnextbr1);						//pcsrc is high when we are in a branch instruction and the condition. (zero flag) are met.

mux2 #(32) pcmux2({6'b0,instr_readdata[25:0]}, result, jump1, pcnextbr2);	//jump1 is high when we jump to value in register.

shiftleft2 jsh(pcnextbr2, jumpsh);											//Instruction in PC are every 4 so we need to multiply by 4.

mux2 #(32) pcmux(pcnextbr1, jumpsh, jump, pcnextbr);						//jump is high when we are in a jump instruction.



	
// Register file

//we added an output: register_v0 so that this value is accessible from the outside of the Mips_cpu at all time.
regfile register(clk, regwrite, instr_readdata[25:21], instr_readdata[20:16], writereg, result, srca, data_writedata, register_v0);

mux2 #(5) wrmux(instr_readdata[20:16], instr_readdata[15:11], regdst1, writereg1);		//regdst1 is high for R-type instructions else select I-type.
mux2 #(5) wrmux2(writereg1, 5'b11111, regdst2, writereg);								//regdst2 is high for link instructions (store value in $31).

adder pcbrlink(pcplus4, 32'b100, pclink);

//Load selector bit (word/byte/LSB...)
loadselector loadsel(data_readdata, loadcontrol, result1);

//Result--value written in register (Load/Branches/Jump)
mux2 #(32) resmux(data_address, result1, memtoreg1, result2);		//memtoreg1 is high for load instructions (value in RAM) else take result from ALU.
mux2 #(32) resmux2(result2, pclink, memtoreg2, result);				//memtoreg2 is high for Branch with condition met and Jump with link instructions.

//ALU file
mux2 #(32) srcbmux(data_writedata, signimm, alusrc, srcb);			//alusrc is high for instructions using Immediate variable else for srcB instr.

alu alumodule(alucontrol, srca, srcb, instr_readdata[10:6], zero, data_address); 

endmodule
