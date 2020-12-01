module alumodule(
	input logic [4:0] control,
	input logic [31:0] a,
	input logic [31:0] b,
	output logic zero,
	output logic [31:0] y);

logic [31:0] x;
logic [64:0] r1,r2,z;
logic i;
reg[31:0] HI,LO;

always @(*)begin
	case(control)
		5'b00000: y <= a & b;						//AND
		5'b00001: y <= a | b;						//OR
		5'b00010: y <= a ^ b;						//XOR
		5'b00011: y <= a + b;						//ADDU
		5'b00100: y <= a + (~b +1);					//SUBU
		5'b00101: y <= (a < b);						//SLT Unsigned
		
		5'b00110: begin								//SLT signed
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
		
		5'b00111: begin											//MULTU Multiplication unsigned
				r1 = {32'b0,a[31:0]};
				r2 = {32'b0,b[31:0]};
				z = r1 * r2;
				HI <= z[63:32];
				LO <= z[31:0];
			 end
		
		5'b01000: begin											//MULT multiplication signed
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
						HI <= z[63:32];
						LO <= z[31:0];
					end
				end else begin
					if((a[31] == 0) & (b[31] == 1))begin
						r1 = {32'b0,a[31:0]};
						r2 = {32'b0,(~b[31:0] +1)};
						z = ~(r1 * r2) +1; 
						HI <= z[63:32];
						LO <= z[31:0];
					end else begin
						r1 = {32'b0,(~a[31:0] +1)};
						r2 = {32'b0,b[31:0]};
						z = ~(r1 * r2) +1; 
						HI <= z[63:32];
						LO <= z[31:0];
					end
				end
			end
				  			  
		5'b01001: y <= a << (b[10:6]);							//shift left logical: we take the shift variable from instr[10:6] included in the Immediate field
		
		5'b01010: y <= a << b;									//shift left logical variable
		
		5'b01011: begin											//shift right arithmetic
				x = a;
				for(i = b[10:6]; i>0; i = i-1)begin
						if(a[31] == 1)
								x = {1'b1,x[31:1]};
						else
								x = {1'b0,x[31:1]};
				end
				y <= x;
			 end
			 
		5'b01100: begin											//shift right logical
				x = a;
				for(i = b[10:6]; i>0; i = i-1)begin
					x = {1'b0,x[31:1]};					
				end
				y <= x;
			 end
			 
//		5'b: y <= a >> (b[10:6]);							//shift right logical

		5'b01101: begin											//shift right arithmetic variable
				x = a;
				for(i = b[31:0]; i>0; i = i-1)begin
						if(a[31] == 1)
								x = {1'b1,x[31:1]};
						else
								x = {1'b0,x[31:1]};
				end
				y <= x;
			 end	
			 	
		5'b01110: begin											//shift right logical variable
				x = a;
				for(i = b[31:0]; i>0; i = i-1)begin
					x = {1'b0,x[31:1]};
				end
				y <= x;
			 end	 	
			 				
//		5'b: y <= a >> b;									//shift right logical variable
		
	

		
		5'b01111: begin										//Divid: DIV
					if(a[31] == b[31])begin
						if((a[31] == 0) & (b[31] == 0))begin
							HI <= a % b;
							LO <= a / b;
						end else begin
							r1 = ~a[31:0] +1;
							r2 = ~b[31:0] +1;
							HI <= -(r1 % r2) + r2;
							LO <= r1 / r2 + 1;
						end
					end else begin
						if((a[31] == 0) & (b[31] == 1))begin
							r2 = ~b[31:0] +1;
							HI <= a % r2;
							LO <= -(a / r2);
						end else begin
							r1 = ~a[31:0] +1;
							HI <= -(r1 % b) + b;
							LO <= -(r1 / b + 1);
						end
					end
				end
		5'b10000: begin										//Divid unsigned: DIVU
					HI <= a % b;
					LO <= a / b;
				end
		5'b10001: y <= HI[31:0];							//MTHI: move to High
		5'b10010: y <= LO[31:0];							//MTLO: move to Low

		5'b10011: begin										 //Branch on < 0 
					if(a < 0)begin			
								y <= 0;
					end else y <= 1;
				end
		
		5'b10100: begin										 //Branch on < 0 /link 
					if(a < 0)begin			
								y <= 0;
					end else y <= 1;
				end

		5'b10101: begin										 //Branch on > 0  
					if(a > 0)begin			
								y <= 0;
					end else y <= 1;
				end
		
		5'b10110: begin										 //Branch on <= 0  
					if(a <= 0)begin			
								y <= 0;
					end else y <= 1;
				end

		5'b10111: begin										 //Branch on != 0  
					if(a != 0)begin			
								y <= 0;
					end else y <= 1;
				end
		
		5'b11000: y <= (b << 16);							//Load upper Immidiate

		5'b11001: y <= a;									//Jump register JR
		
	endcase
end


		always @(y)begin
				if(y==0)begin
					zero <= 1;
				end else begin
					zero <= 0;
				end
		end

endmodule








/*		Synthax error

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
endfunction

*/
