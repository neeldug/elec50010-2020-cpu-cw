module data_mem (
    input logic clk,
    input logic [31:0] data_address,
    input logic [31:0] data_writedata,
    input logic data_write,
    output logic [31:0] data_readdata
);

  parameter str DATA_INIT_FILE = "";

  reg [31:0] dmem[4294967296];

  //data initialization
  initial begin
    integer i;
    for (i = 0; i < 4294967296; i++) begin
      dmem[i] = 0;
    end

<<<<<<< HEAD
		if(DATA_INIT_FILE != "") begin
			$readmemh(DATA_INIT_FILE, dmem);
		end
	end
=======
    if (DATA_INIT_FILE != "") begin
      $readmemh(DATA_INIT_FILE, imem);
    end
  end
>>>>>>> 56aa099aaf767ccca6ccd805cd1f0cfb3ea874e9

  //clockedge read and write with write control signal
  always @(posedge clk) begin
    if (data_write) begin
      dmem[data_address] <= data_writedata;
    end
    data_readdata <= dmem[data_address];
  end
endmodule
