module instr_mem(
	input logic[31:0] pc,
	output logic[31:0] instr
);

	parameter INSTR_INIT_FILE = "";
	
	reg [31:0] imem [16777215:0];
	
	//initialization
	initial begin 
		integer i;
		for (i=0; i<16777216; i++) begin
			imem[i] = 0;
		end
		
		if(INSTR_INIT_FILE != "") begin
			$readmemh(INSTR_INIT_FILE, imem)
		end
	end
	
	//making the async read
	always_comb begin
		instr <= imem[pc];
	end
endmodule
