module loadselector(
	input logic [31:0] a,
	input logic [2:0] controls,
	output logic [31:0] y
	);

reg [31:0] z;

always @(*)begin
	case(controls)
		3'b000: begin					//Load byte signed
					if(a[7] == 1)begin
						y = {24'b1, a[7:0]};
					end else begin
						y = {24'b0, a[7:0]};
					end
				end
				
		3'b001: begin
			y = {24'b0, a[7:0]};	//Load byte unsigned
			end
		3'b010: begin					//Load halfword signed
					if(a[15] == 1)begin
						y = {16'b1, a[15:0]};
					end else begin
						y = {16'b0, a[15:0]};
					end
				end 
				
		3'b011: y = {16'b0, a[15:0]};	//Load halfword unsigned
		
//		3'b100: y = b;					//Load upper Immediate
		
		3'b101: y = a;					//Load word
		
		3'b110: begin					//Load word left
					if((4-(a%4)) == 0)begin
						y = {a[7:0], 24'b0};
					end else if((4-(a%4)) == 1)begin
						y = {a[15:0], 16'b0};
					end else if((4-(a%4)) == 2)begin
						y = {a[23:0], 8'b0};
					end else begin
						y = a[31:0];
					end
				 end
				 
		3'b111: begin					//Load word right
					if((a%4) == 0)begin
						y = {24'b0, a[7:0]};
					end else if((a%4) == 1)begin
						y = {16'b0, a[15:0]};
					end else if((a%4) == 2)begin
						y = {8'b0, a[23:0]};
					end else begin
						y = a[31:0];
					end
				 end
		
		default: y = a[31:0];	
	endcase
	end

always @(y)begin
	z = y;
	end
	
endmodule
	
