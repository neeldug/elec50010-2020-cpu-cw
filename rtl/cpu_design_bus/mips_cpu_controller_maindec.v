module maindec (
	input logic clk,
	reset,
	input logic waitrequest,
    input logic [5:0] op,
    funct,
    input logic [4:0] dest,
    output logic memtoreg1,
    memwrite,
    output logic branch,
    alusrca,
    output logic regdst2,
    regdst1,
    output logic regwrite,
    output logic jump1,
    jump,
    output logic iord, 
    irwrite, 
    pcwrite
    output logic [1:0] alusrcb,
    output logic [1:0] aluop,
    output logic [2:0] state,
    output logic [2:0] loadcontrol
);
initial begin
	alusrca = 0;
	alusrcb = 00;
	memtoreg1 = 0;
	memtoreg2 = 0;
	memwrite = 0;
	branch = 0;
	regdst1 = 1;
	regdst2 = 0;
	regwrite = 0;
	jump1 = 0;
	jump = 0;
	iord = 0;
	irwrite = 0;
	pcwrite = 0;
	aluop = 00;
end

/*	State:
	000 : Fetch
	001 : Decode
	010 : S2
	011 : S3
	100 : S4
*/

always @(posedge clk) begin
	if (reset) begin
		state <= 000;
	end 
	
	else if (waitrequest == 1) begin	//implement waitrequest signal ??
	end
	
	else if (state == 000) begin	//Fetch state: PC incrementation
		iord <= 0;
		alusrca <= 0;
		alusrcb <= 01;
		aluop <= 00;
		pcsrc <= 00;		//to check
		irwrite <= 1;
		pcwrite <= 1;
		state <= 001;
	end
	else if (state == 001) begin	//Decode instruction: Branch instr
		alusrca <= 0;
		alusrcb <= 11;
		aluop <= 00;
		state <= 010;
	end
	else if (state == 010) begin	//S2 state: ALU operations
		case (op)
			6'b000000:  		//R-type instructions
				case (funct)
					6'b010001 | 6'b010100: begin	//MTHI MTLO
						alusrca <= 1;
						alusrcb <= 00;
						aluop <= 10;
						state <= 000;
					end
					6'b001001: begin	//Jump register
						aluop <= 01;
						pcsrc <= 10;
						pcwrite <= 1;
						state <= 000;
						end
					6'b001001: begin	//Jump register and link
						aluop <= 01;
						pcsrc <= 10;
						pcwrite <= 1;
						state <= 011;
						end
					default: begin	//R-type instruction basic
						alusrca <= 1;
						alusrcb <= 00;
						aluop <= 10;
						state <= 011;
					end
				endcase
			6'b000100 | 6'b000111 | 6'b000110 | 6'b000101: begin	//Branches
				alusrca <= 1;
				alusrcb <= 00;
				aluop <= 10;
				pcsrc <= 01;
				branch <= 1;
				state <= 000;
			end
			6'b0000001:	//branches
				case (dest)
				 5'b10001 | 5'b10000: begin	//Branch with link
					alusrca <= 1;
					alusrcb <= 00;
					aluop <= 10;
					pcsrc <= 01;
					branch <= 1;
					state <= 011;
				 end
				 default: begin
				 	alusrca <= 1;
					alusrcb <= 00;
					aluop <= 10;
					pcsrc <= 01;
					branch <= 1;
					state <= 000;
				 end
				endcase
			6'b001001 | 6'b001100 | 6'b001101 | 6'b001110 | 6'b001010 | 6'b001011 | 6'b001111: begin	//R-type with immediate & LUI at end.
				alusrca <= 1;
				alusrcb <= 10;
				aluop <= 10;
				state <= 011;
				end
			6'b000010: begin	//Jump
				aluop <= 01;
				pcsrc <= 10;
				pcwrite <= 1;
				state <= 000;
				end
			6'b000011: begin	//Jump and Link
				aluop <= 01;
				pcsrc <= 10;
				pcwrite <= 1;
				state <= 011;
				end
			6'b100000 | 6'b100100 | 6'b100001 | 6'b100101 | 6'b100011 | 6'b100010 | 6'b100110 | 6'b101000 | 6'b101001 | 6'b101011: begin //store and load instructions except for LUI
				alusrca <= 1,
				alusrcb <= 10;
				aluop <= 00;
				state <= 011;
				end
			default: begin		//error to check
				state <= 000;
				active <= 0;
				end
		endcase
	end
	else if (state == 011) begin
		case (op)
			6'b100000 | 6'b100100 | 6'b100001 | 6'b100101 | 6'b100011 | 6'b100010 | 6'b100110: begin	//Load instructions
				iord <= 1;
				state <= 100;
				end
			6'b101000 | 6'b101001 | 6'b101011: begin	//Store instructions
				iord <= 1;
				memwrite <= 1;
				state <= 000;
				end
			6'b000000:  		//R-type instructions
				case (funct)
					6'b001001: begin	//Jump register and link
						regdst2 <= 1;
						memtoreg <= 0;
						regwrite <= 1;
						state <= 000;
						end
					default: begin	//R-type instruction basic.
						regdst1 <= 1;
						regdst2 <= 0
						memtoreg <= 0;
						regwrite <= 1;
						state <= 000;
					end
				endcase
			6'b000001: begin	//branch and link.
				regdst2 <= 1;
				memtoreg <= 0;
				regwrite <= 1;
				state <= 000;
				end
			6'b001001 | 6'b001100 | 6'b001101 | 6'b001110 | 6'b001010 | 6'b001011 | 6'b001111: begin	//R-type with immediate & LUI at end.
				regdst1 <= 1;
				regdst2 <= 0
				memtoreg <= 0;
				regwrite <= 1;
				state <= 000;
				end
			default: begin	//error to check.
				state <= 000;
				active <= 0;
				end
		endcase
	end
	else if (state == 100) begin
		regdst <= 0;
		regdst2 <= 0;
		memtoreg <= 1;
		regwrite <= 1;
		state <= 000;
	end
	else if (active == 0) begin
		// do nothing.
	end
	else begin	//error state.
		state <= 000;
		active <= 0;
	end
end 
endmodule		 
