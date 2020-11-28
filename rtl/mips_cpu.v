module CPU_MIPS_harvard(
	input clk, reset,
	output active,
	output [31:0] register_v0,
	
	input clk_enable,
	
	output [31:0] instr_address,	//PC Next
	input [31:0] instr_readdata,	//Data stored at address determined by PCnext
	
	output [31:0] data_address,		//ALU_result
	output data_write,				//control signal Data memory write enable for data
	output data_read,
	output [31:0] data_writedata,
	input [31:0] data_readdata,
	
	

	input [31:0] instr,
	output		memwrite,
	output [31:0] aluout, writedata,
	input [31:0] readdata);
	
wire memtoreg, branch, alusrc, regdst, regwrite, jump;
wire [2:0] alucontrol;

controller control(instr_readdata[31:26], instr_readdata[5:0], zero, memtoreg, memwrite, pcsrc, alusrc, 			 regdst, regwrite, jump, alucontrol);

datapath datap(clk, rest, memtoreg, pcsrc, alusrc, regdst, regwrite, jump, alucontrol, zero, pc, instr, aluout, data_writedata, data_readdata);

endmodule

module controller(
	input [5:0] op, funct,
	input zero
	output memtoreg, memwrite,
	output pcsrc, alusrc,
	output regdst, regwrite,
	output jump,
	output [2:0] alucontrol);
	
wire [1:0] aluop;
wire branch;

maindec md(op, memtoreg, memwrite, branch, alusrc, regdst, regwrite, jump, aluop);

aludec ad(funct, aluop, alucontrol);

assign pcsrc = branch & zero;

endmodule

module maindec(
	input [5:0] op, funct,
	output memtoreg, memwrite,
	output branch, alusrc
	output regdst, regwrite,
	output jump,
	output [1:0] aluop);
	
reg [8:0] controls;

assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop} = controls;

// Assign 8 elements names as aluop consist of 2 bits so rightfully fills the reg controls.
// Correspond to the bits below from left to right in the same order (starting with regwrite and ending with aluop).

always @(*)
	case(op)
		6'b000000: controls <= 9'b110000010; //R-type instruction
		6'b100011: controls <= 9'b101001000; //LW
		6'b101011: controls <= 9'b001010000; //SW
		6'b000100: controls <= 9'b000100001; //BEQ
		6'b001000: controls <= 9'b101000000; //ADDI
		6'b000010: controls <= 9'b000000100; //J
		default:   controls <= 9'bxxxxxxxxx; //???
	endcase
endmodule

// We are currently setting all the control signals by looking at the opcode of the instrunctions
// We created an reg (=array) of control signals so that it is easier to implement.
// In order to understand this section please refer to page 376 of the book (table 7.3)

module aludec(
	input [5:0] funct,
	input [1:0] aluop,
	output reg [2:0] alucontrol);

always @(*)
	case(aluop)							//edge what if we have a 2'b11 eventhough it is illegal
	
		2'b00: alucontrol <= 3'b010; //ADD
		2'b01: alucontrol <= 3'b110; //SUB
		default: case(funct)
			6'b100000: alucontrol <= 3'b010; //ADD
			6'b100010: alucontrol <= 3'b110; //SUB
			6'b100100: alucontrol <= 3'b000; //AND
			6'b100101: alucontrol <= 3'b001; //OR
			6'b101010: alucontrol <= 3'b111; //Set Less Then (SLT)
			default:   alucontrol <= 3'bxxx; //???
		endcase
	endcase
endmodule

// In this module we are setting the control signals for the ALU. Refer to the table 7.2 page 376.
// Note: The aluop can't be 2'b11. 
// The default: case(funct) replaces an iterative: 2'b10 & 6'bxxxxxx (funct) 

module datapath(
	input clk, reset,
	input memtoreg, pcsrc,
	input alusrc, regdst,
	input regwrite, jump,
	input [2:0] alucontrol,
	output zero,
	input [31:0] instr,
	input [31:0] readdata,
	output [31:0] pc,
	output [31:0] aluout, writedata);

wire [4:0] writereg;
wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
wire [31:0] signimm, signimmsh;
wire [31:0] srca, srcb;
wire [31:0] result;

// Program counter regfile

flipflopr #(32) pcreg(clk, reset, pc, pcnext);

adder pcplus4(pcnext, 32'b100, pcplus4);

shiftleft2 immshift(signimm, signimmsh);

adder pcbranch(signimmsh, pcplus4, pcbranch);

mux2 #(32) pcmux(pcplus4, pcbranch, pcsrc, pcnextbr);

//another mux ?

 
		
		




// Implementation of reusable functions used in datapath

module mux2 #(parameter WIDTH)(
	input [WIDTH - 1:0] a, b,
	input s,
	output [WIDTH - 1:0] y);

	assign y = s ? a : b;
endmodule

module adder(
	input [31:0] a,b,
	output [31:0] y);

	assign y = a + b;
endmodule

module shiftleft2(
	input [31:0] a,
	output [31:0] y);

	assign y = {{a[29:0]} , 2'b00};
endmodule
	
module flipflopr #(parameter WIDTH)(
	input clk, reset,
	input [WIDTH-1:0] d,
	output reg [WIDTH-1:0] q);

	always @(posedge clk, posedge reset)
		if(reset) q <= 0;
		else	  q <= d;
endmodule 
	
module signext(
	input [15:0] instr,
	output [31:0] signimm);
	
	assign signimm = {{16{instr[15]}},instr};
endmodule
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	
