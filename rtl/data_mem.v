module instr_mem(
	input logic clk,
	input logic[31:0] data_adress,
	input logic[31:0] data_writedata,
	input logic data_write,
	output logic[31:0] data_readdata
);

	parameter DATA_INIT_FILE = "";
	
	reg [31:0] dmem [16777215:0];
	
	//data initialization
	initial begin 
		integer i;
		for (i=0; i<16777216; i++) begin
			dmem[i] = 0;
		end
		
		if(DATA_INIT_FILE != "") begin
			$readmemh(DATA_INIT_FILE, imem)
		end
	end
	
	//clockedge read and write with write control signal
	always @(posedge clk) begin
		if(data_write) begin 
			dmem[data_adress] <= data_writedata;
		end
		data_readdata <= dmem[data_adress];
	end
endmodule
