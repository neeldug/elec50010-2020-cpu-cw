module alumodule(
	input [2:0] control,
	input [31:0] a,
	input [31:0] b,
	output zero,
	output [31:0] y);

case(funct)



module ands(
	input [31:0] a,b,
	output [31:0] y);
	
	assign y = a & b;
endmodule

module ors(
	input [31:0] a,b,
	output [31:0] y);
 	
 	assign y = a | b;
endmodule

module xors(
	input [31:0] a,b,
	output [31:0] y);
	
	assign y = a^b;
endmodule

module add(
	input [31:0] a,b,
	output [31:0] y);
	
	assign y = a+b;
endmodule

module beq(
	input [31:0] a,b,
	output [31:0] y);
	
	assign y = (a==b);
endmodule

module bgez(
	input [31:0] a,
	output [31:0] y);
	
	assign y = (a>=0);
endmodule

// module bgezal same as bgez solution add control signal to link PCplus4 and register $31

module bgtz(
	input [31:0] a,
	output [31:0] y);
	
	assign y = (a > 0);
endmodule

module blez(
	input [31:0] a,
	output [31:0] y);
	
	assign y = (a <= 0);
endmodule
	
module bltz(
	input [31:0] a,
	output [31:0] y);
	
	assign y = (a < 0);
endmodule

module bne(
	input [31:0] a,b,
	output [31:0] y);
	
	assign y = (a != b);
endmodule

module div(
	input [31:0] a,
	output [31:0] y);
	
	assign y = (a <= 0);
endmodule







































	
