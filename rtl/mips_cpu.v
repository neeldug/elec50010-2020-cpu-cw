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
	input [31:0] data_readdata);
	
wire memtoreg, branch, alusrc, regdst, regwrite, jump;
wire [2:0] alucontrol;

controller control(instr_readdata[31:26], instr_readdata[5:0], instr_readdata[20:16] zero, memtoreg, data_write, pcsrc, alusrc, regdst, regwrite, jump, alucontrol);

datapath datap(clk, reset, clk_enable, memtoreg, pcsrc, alusrc, regdst, regwrite, jump, alucontrol, zero, pc, instr_readdata, aluout, data_writedata, data_readdata);

endmodule

module controller(
	input [5:0] op, funct,
	input [4:0] dest,
	input zero
	output memtoreg, data_write,
	output pcsrc, alusrc,
	output regdst, regwrite,
	output jump,
	output [2:0] alucontrol);
	
wire [1:0] aluop;
wire branch;

maindec md(op, memtoreg, data_write, branch, alusrc, regdst, regwrite, jump, aluop);

aludec ad(funct, aluop, alucontrol);

assign pcsrc = branch & zero;

endmodule

module maindec(
	input [5:0] op, funct,
	input [4:0] dest,
	output memtoreg, data_write,
	output branch, alusrc
	output regdst, regwrite,
	output jump,
	output [1:0] aluop);
	
reg [8:0] controls;

assign {regwrite, regdst, alusrc, branch, data_write, memtoreg, jump, aluop} = controls;

// Assign 8 elements names as aluop consist of 2 bits so rightfully fills the reg controls.
// Correspond to the bits below from left to right in the same order (starting with regwrite and ending with aluop).

always @(*)
	case(op)
		6'b000000: case(funct)
						6'b001001: controls <= 9'b100000100; //Jump and link register
						6'b001000: controls <= 9'b010000110; //Jump register
						default: controls <= 9'b110000010; //R-type instruction
					endcase
		6'b100000: controls <= 9'b101001000; //Load byte
		6'b100100: controls <= 9'b101001000; //Load byte unsigned
		6'b100001: controls <= 9'b101001000; //Load halfword
		6'b100101: controls <= 9'b101001000; //Load halfword unisigned
		6'b001111: controls <= 9'b101001000; //Load upper immidiate
		6'b100011: controls <= 9'b101001000; //Load word
		6'b100010: controls <= 9'b101001000; //Load word left
		6'b100110: controls <= 9'b101001000; //Load word right
		6'b101000: controls <= 9'b001010000; //Store byte
		6'b101001: controls <= 9'b001010000; //Store halfword
		6'b101011: controls <= 9'b001010000; //Store word
		6'b000100: controls <= 9'b000100001; //Branch on = 0
		6'b000001: case(dest)
						5'b00001: controls <= 9'b000100001; //Branch on >= 0
						5'b10001: controls <= 9'b100100001; //Branch on >= 0 /link (regwrite active)
						5'b00000: controls <= 9'b000100001; //Branch on < 0
						5'b10000: controls <= 9'b100100001; //Branch on < 0 /link
						default: controls <= 9'bxxxxxxxxx;
					endcase
		6'b000111: controls <= 9'b000100001; //Branch on > 0
		6'b000110: controls <= 9'b000100001; //Branch on <= 0
		6'b000101: controls <= 9'b000100001; //Branch on != 0
		6'b001001: controls <= 9'b101000010; //ADD unsigned immediate
		6'b000010: controls <= 9'b000000100; //Jump
		6'b000011: controls <= 9'b100000100; //Jump and link
		6'b001100: controls <= 9'b101000010; //ANDI
		6'b001101: controls <= 9'b101000010; //ORI
		6'b001110: controls <= 9'b101000010; //XORI
		6'b001010: controls <= 9'b101000010; //Set on less than immediate (signed)
		6'b001011: controls <= 9'b101000010; //Set on less than immediate unsigned
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
			6'b100100: alucontrol <= 
			default:   alucontrol <= 3'bxxx; //???
		endcase
	endcase
endmodule

// In this module we are setting the control signals for the ALU. Refer to the table 7.2 page 376.
// Note: The aluop can't be 2'b11. 
// The default: case(funct) replaces an iterative: 2'b10 & 6'bxxxxxx (funct) 

module datapath(
	input clk, reset, clk_enable,
	input memtoreg, pcsrc,
	input alusrc, regdst,
	input regwrite, jump,
	input [2:0] alucontrol,
	output zero,
	input [31:0] instr_readdata,
	input [31:0] data_readdata,
	output [31:0] pc,
	output [31:0] data_address, data_writedata);

wire [4:0] writereg;
wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
wire [31:0] signimm, signimmsh;
wire [31:0] srca, srcb;
wire [31:0] result;

// Program counter regfile

flipflopr #(32) pcreg(clk, reset, clk_enable, pc, pcnext);

adder pcplus4(pcnext, 32'b100, pcplus4);

shiftleft2 immshift(signimm, signimmsh);

adder pcbranch(signimmsh, pcplus4, pcbranch);

mux2 #(32) pcmux(pcplus4, pcbranch, pcsrc, pcnextbr);

//another mux ?

 
		
//Register file
regfile register(clk, regwrite, instr_address[25:21], instr_address[20:16], write_reg, result, srca, data_writedata);

mux2 #(5) wrmux(instr_address[20:16], instr_address[15:11], regdst, writereg);

mux2 #(32) resmux(data_address, data_readdata, memtoreg, result);

signext se(instr_address[15:0], signimm);

// ALU file
mux2 #(32) srcbmux(data_writedata, signimm, alusrc, srcb);

alumodule alu(alucontrol, srca, srcb, zero, data_address); 

endmodule



// Implementation of the register file
module regfile(
	input 		clk,
	input 		we3,
	input [4:0] ra1, ra2, wa3,
	input [31:0] wd3,
	output [31:0] rd1, rd2
	);
	
	reg[31:0] rf[31:0];
	//three ported register file
	//read two ports combinationally
	//write third port on rising edge of clock
	//register 0 hardwired to 0
	
	always @(posedge clk)
		if(we3) rf[wa3] <= wd3;
		
	assign rd1 = (ra1 ! = 0) ? rf[ra1] : 0;
	assign rd2 = (ra2 ! = 0) ? rf[ra2] : 0;
endmodule

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
	input clk, reset, clk_enable,
	input [WIDTH-1:0] d,
	output reg [WIDTH-1:0] q);

	always_ff @(posedge clk, posedge reset)
		if(reset) 				q <= 0;
		else if(clk_enable) 	q <= d;
endmodule 
	
module signext(
	input [15:0] instr_readdata,
	output [31:0] signimm);
	
	assign signimm = {{16{instr_readdata[15]}},instr_readdata};
endmodule
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	
