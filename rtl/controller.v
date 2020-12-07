module controller(
	input logic [5:0] op, funct,
	input logic [4:0] dest,
	input logic zero,
	output logic memtoreg2, memtoreg1,
	output logic data_write,
	output logic pcsrc, alusrc,
	output logic regdst2, regdst1,
	output logic regwrite,
	output logic jump1, jump,
	output logic [4:0] alucontrol,
	output logic [2:0] loadcontrol);
	
logic [1:0] aluop;
logic branch;

maindec md(op, funct, dest, memtoreg2, memtoreg1, data_write, branch, alusrc, regdst2, regdst1, regwrite, jump1, jump, aluop, loadcontrol);

aludec ad(funct, op, dest, aluop, alucontrol);
	always @(*) begin
		assign pcsrc = branch & zero;
	end
endmodule
