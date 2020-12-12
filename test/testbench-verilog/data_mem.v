module data_mem (
    input logic clk,
    input logic [31:0] data_address,
    input logic [31:0] data_writedata,
    input logic data_write,
    output logic [31:0] data_readdata
);

  parameter DATA_INIT_FILE = "";
  localparam  START = 32'h10000000;

  reg [7:0] dmem[START:START+511];

  //data initialization
  initial begin
    integer i;
    for (i = START; i < START+511; i++) begin
      dmem[i] = 0;
    end

    if (DATA_INIT_FILE != "") begin
      $readmemh(DATA_INIT_FILE, dmem);
    end
  end

  //clockedge read and write with write control signal
  always @(posedge clk) begin
    if (data_write) begin
      dmem[data_address] <= data_writedata[7:0];
      dmem[data_address+1] <= data_writedata[15:8];
      dmem[data_address+2] <= data_writedata[23:16];
      dmem[data_address+3] <= data_writedata[31:24];
    end
    data_readdata <= {dmem[data_address], dmem[data_address+1], dmem[data_address+2], dmem[data_address+3]};
  end
endmodule
