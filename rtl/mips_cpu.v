module CPU_MIPS_harvard(
	input logic clk, reset,
	output logic active,
	output logic [31:0] register_v0,
	
	input logic clk_enable,
	
	output logic [31:0] instr_address,		//PC Next
	input logic [31:0] instr_readdata,		//Data stored at address determined by PCnext
	
	output logic [31:0] data_address,		//ALU_result
	output logic data_write,				//control signal Data memory write enable for data
	output logic data_read,
	output logic [31:0] data_writedata,
	input logic [31:0] data_readdata);
	
logic memtoreg1, memtoreg2, branch, alusrc, regdst1, regdst2, regwrite, jump1, jump, zero, pcsrc;

logic [4:0] alucontrol;
logic [2:0] loadcontrol;

controller control(instr_readdata[31:26], instr_readdata[5:0], instr_readdata[20:16], zero, memtoreg2, memtoreg1, data_write, pcsrc, alusrc, regdst2, regdst1, regwrite, jump1, jump, alucontrol, loadcontrol);

datapath datap(clk, reset, clk_enable, memtoreg2, memtoreg1, alusrc, pcsrc, regdst2, regdst1, regwrite, jump1, jump, alucontrol, loadcontrol, zero, instr_address, instr_readdata, data_readdata, data_address, data_writedata, register_v0);

endmodule
