module alumodule(
	input [2:0] control,
	input [31:0] a,
	input [31:0] b,
	output zero,
	output [31:0] y);

reg[31:0] x;
reg[64:0] r1,r2,z;
reg[31:0] HI,LO;

case(control)
		3'b00000: y <= a & b;						//AND
		3'b00001: y <= a | b;						//OR
		3'b00010: y <= a ^ b;						//XOR
		3'b00011: y <= a + b;						//ADD
		3'b00100: y <= a + (~b +1);					//SUBU
		3'b00101: y <= (a < b);						//SLT Unsigned
		
		3'b00110: begin								//SLT signed
					if(a[31] != b[31])begin			
							if(a[31] > b[31])begin
									y <= 1;
							end else begin
									y <= 0;
							end
					end else begin
							if(a<b)begin
									y <= 1;
							end else begin
									y <= 0;
							end
					end
				  end
		
		3'b00111: begin											//MULTU Multiplication unsigned
				r1 = {32'b0,a[31:0]};
				r2 = {32'b0,b[31:0]};
				z = r1 * r2;
				HI <= z >> 32;
				LO <= (z << 32) >> 32;
			 end
		
		3'b01000: begin											//MULT multiplication signed
				if(a[31] == b[31])begin
					if((a[31] == 0) & (b[31] == 0))begin
						r1 = {32'b0,a[31:0]};
						r2 = {32'b0,b[31:0]};
						z = r1 * r2;
						HI <= z >> 32;
						LO <= (z << 32) >> 32;
					end else begin
						r1 = {32'b0,(~a[31:0] +1)};
						r2 = {32'b0,(~b[31:0] +1)};
						z = r1 * r2;
						HI <= z >> 32;
						LO <= (z << 32) >> 32;
					end
				end else begin
					if((a[31] == 0) & (b[31] == 1))begin
						r1 = {32'b0,a[31:0]};
						r2 = {32'b0,(~b[31:0] +1)};
						z = ~(r1 * r2) +1; 
						HI <= sra32(z[63:0]);
						LO <= sra32(z << 32);
					end else begin
						r1 = {32'b0,(~a[31:0] +1)};
						r2 = {32'b0,b[31:0]};
						z = ~(r1 * r2) +1; 
						HI <= sra32(z[63:0]);
						LO <= sra32(z << 32);
					end
				end
			end
				  			  
		3'b01001: y <= a << (b[10:6]);							//shift left logical: we take the shift variable from instr[10:6] included in the Immediate field
		
		3'b01010: y <= a << b;									//shift left logical variable
		
		3'b01011: begin											//shift right arithmetic
				x = a;
				for(i = b[10:6]; i>0; i = i-1)begin
						if(a[31] == 1)
								x = {1'b1,x[31:1]};
						else
								x = {1'b0,x[31:1]};
				end
				y <= x;
			 end
			 
		3'b01100: begin											//shift right logical
				x = a;
				for(i = b[10:6]; i>0; i = i-1)begin
					x = {1'b0,x[31:1]};					
				end
				y <= x;
			 end
			 
//		3'b: y <= a >> (b[10:6]);							//shift right logical

		3'b01101: begin											//shift right arithmetic variable
				x = a;
				for(i = b[31:0]; i>0; i = i-1)begin
						if(a[31] == 1)
								x = {1'b1,x[31:1]};
						else
								x = {1'b0,x[31:1]};
				end
				y <= x;
			 end	
			 	
		3'b01110: begin											//shift right logical variable
				x = a;
				for(i = b[31:0]; i>0; i = i-1)begin
					x = {1'b0,x[31:1]};
				end
				y <= x;
			 end	 	
			 				
//		3'b: y <= a >> b;									//shift right logical variable
		
		3'b00111: y <= (b << 16);							//Load upper Immidiate
		3'b01000: y <= ;
		3'b0: y <= ;
		
		always @(y)begin
				if(y==0)begin
					zero <= 1;
				end else begin
					zero <= 0;
				end
		end

endmodule


function [63:0] sra32 (input [63:0] a);
reg [31:0] x;
		
	begin											
		x = a;
		for(i = 32; i>0; i = i-1)begin
			if(a[63] == 1)
				x = {1'b1,x[63:1]};
			else
				x = {1'b0,x[63:1]};
			end
		sra32 = x;
	end



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







































	
