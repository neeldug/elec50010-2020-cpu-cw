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
	output logic [31:0] pc,
	input logic [31:0] instr_readdata,
	input logic [31:0] data_readdata,
	output logic [31:0] data_address, data_writedata,
	output logic [25:0] instr_address,
	output logic [31:0] register_v0);


logic [4:0] writereg1, writereg;
logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch, pclink;
logic [31:0] signimm, signimmsh, pcnextbr1, pcnextbr2;
logic [31:0] srca, srcb;
logic [31:0] result2, result1, result;



// Program counter regfile
flipflopr #(32) pcreg(clk, reset, clk_enable, pcnextbr, pcnext);

adder pcpl4(pcnext, 32'b100, pcplus4);

signext se(instr_address[15:0], signimm); 

shiftleft2 immshift(signimm, signimmsh);

adder pcbr(signimmsh, pcplus4, pcbranch);

mux2 #(32) pcmux1(pcplus4, pcbranch, pcsrc, pcnextbr1);


mux2 #(32) pcmux2({6'b0,instr_address}, result, jump1, pcnextbr2);

mux2 #(32) pcmux(pcnextbr1, pcnextbr2, jump, pcnextbr);

//another mux ?

	
//Register file
regfile register(clk, regwrite, instr_address[25:21], instr_address[20:16], writereg, result, srca, data_writedata, register_v0);

mux2 #(5) wrmux(instr_address[20:16], instr_address[15:11], regdst1, writereg1);
mux2 #(5) wrmux2(writereg1, 5'b11111, regdst2, writereg);

adder pcbrlink(pcplus4, 32'b100, pclink);

//Load selector bit (word/byte/LSB...)
loadselector loadsel(data_readdata, loadcontrol, result1);

mux2 #(32) resmux(data_address, result1, memtoreg1, result2);
mux2 #(32) resmux2(result2, pclink, memtoreg2, result);

//ALU file
mux2 #(32) srcbmux(data_writedata, signimm, alusrc, srcb);

alumodule alu(alucontrol, srca, srcb, zero, data_address); 

endmodule
