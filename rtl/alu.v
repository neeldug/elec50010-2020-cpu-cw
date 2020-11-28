module alumodule(
	input [2:0] control,
	input [31:0] a,
	input [31:0] b,
	output zero,
	output [31:0] y);




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
