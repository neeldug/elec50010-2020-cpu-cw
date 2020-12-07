module loadstore(
	input logic [31:0] a,
	input logic [3:0] controls,
	output logic [31:0] y
	);

reg [31:0] z;

always @(*)begin
	case(controls)
		4'b0000: begin					//Load byte signed
					if(a[7] == 1)begin
						y = {24'b1, a[7:0]};
					end else begin
						y = {24'b0, a[7:0]};
					end
				end
				
		4'b0001: y = {24'b0, a[7:0]};	//Load byte unsigned
		
		4'b0010: begin					//Load halfword signed
					if(a[15] == 1)begin
						y = {16'b1, a[15:0]};
					end else begin
						y = {16'b0, a[15:0]};
					end
				end 
				
		4'b0011: y = {16'b0, a[15:0]};	//Load halfword unsigned
		
		4'b0100: y = (b << 16);			//Load upper Immediate
		
		4'b0101: y = a;					//Load word
		
		4'b0110: begin					//Load word left
					if( == 0)begin
						y = {a[7:0], 24'b0};
					end else if( == 1)begin
						y = {a[15:0], 16'b0};
					end else if( == 2)begin
						y = {a[23:0], 8'b0};
					end else begin
						y = a[31:0]
					end
				 end
				 
		4'b0111: begin					//Load word right
					if( == 0)begin
						y = {24'b0, a[7:0]};
					end else if( == 1)begin
						y = {16'b0, a[15:0]};
					end else if( == 2)begin
						y = {8'b0, a[23:0]};
					end else begin
						y = a[31:0]
					end
				 end
		
		default: y = a[31:0];	
	endcase
	end

always @(y)begin
	z = y;
	end
	
endmodule
	
