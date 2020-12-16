module datapath(
	input logic clk, reset,
	input logic memtoreg2, memtoreg1,
	input logic alusrc, pcsrc,
	input logic regdst2, regdst1,
	input logic regwrite,
	input logic jump1, jump,
	
	input logic iord, irwrite,
	input logic alusrca,
	input logic [1:0] alusrcb,
	
	
	input logic [4:0] alucontrol,
	input logic [2:0] loadcontrol,
	output logic zero,
	output logic [31:0] address,
	input logic [31:0] readdata,
	output logic [31:0] writedata,
	output logic [31:0] register_v0);

logic [31:0] pcout;
logic [31:0] instr, data;
logic [31:0] rd1, rd2, rda, srca, srcb;
logic [31:0] signimm;
logic [31:0] aluresult, aluout;

//PC register:
flipflopr #(32) pcregist(.clk(clk), .reset(reset), .enable(1), .d(aluresult), .q(pcout));

//selector Instruction/Data:
mux2 #(32) (.a(pcout), .b(aluout), .s(iord), .y(address));

//Memory register:
flipflop #(32) IR(.clk(clk), .reset(reset), .enable(irwrite), .d(readdata), .q(instr));

flipflop #(32) DATAreg(.clk(clk), .reset(reset), .enable(1), .d(readdata), .q(data));


//Register file block:
regfile register(.clk(clk), .reset(reset), .we3(regwrite), .ra1(instr[25:21]), .ra2(), .wa3(instr[20:16]), .wd3(data), .rd1(rd1), .rd2(rd2), .reg_v0(register_v0));

flipflop #(32) rdastore(.clk(clk), .reset(reset), .enable(1), .d(rd1), .q(rda));

signext se(instr[15:0], signimm);


//ALU module:
alu alumodule(.reset(reset), .control(alucontrol), .a(srca), .b(srcb), .shamt(instr[10:6]), .zero(zero), .y(aluresult)); 

mux2 #(32) srcAsel(.a(pcout), .b(rda), .s(alusrca), .y(srca));
mux4 #(32) srcBsel(.a(), .b(3'b100), .c(signimm), .d(), .s(alusrcb), .y(srcb));

flipflop #(32) alureg(.clk(clk), .reset(reset), .enable(1), .d(aluresult), .q(aluout));














