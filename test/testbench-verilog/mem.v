module mem(
  input logic clk,
  input logic [31:0] address,
  input logic write,
  input logic read,
  input logic [31:0] writedata,
  input logic [3:0] byteenable,
  output logic waitrequest,
  output logic [31:0] readdata
);

  parameter INSTR_INIT_FILE = "";
  parameter DATA_INIT_FILE = "";

  localparam DATA_START = 32'h10000000;
  localparam INSTR_START = 32'hBFC00000;

  reg [7:0] data[DATA_START:DATA_START+511];
  reg [7:0] instr[INSTR_START:INSTR_START+511];

  initial begin
    integer i;
    for (i = START; i < START+511; i++) begin
      data[i] = 0;
      instr[i] = 0;
    end

    if (DATA_INIT_FILE != "") begin
      $readmemh(DATA_INIT_FILE, data);
    end

    if (INSTR_INIT_FILE != "") begin
      $readmemh(INSTR_INIT_FILE, instr);
    end

  end

  assign waitrequest = 0;

  always @(posedge clk) begin
    if (read) begin
      if (address[31]) begin
	if (byteenable[0]) begin
	  readdata[7:0] <= instr[address];
	end
	if (byteenable[1]) begin	
	  readdata[15:8] <= instr[address+1];
	end
	if (byteenable[2]) begin
	  readdata[23:16] <= instr[address+2];
	end
	if (byteenable[3])
	  readdata[31:24] <= instr[address+3];
	end
      end
      else begin
	if (byteenable[0]) begin
	  readdata[7:0] <= data[address];
	end
	if (byteenable[1]) begin
	  readdata[15:8] <= data[address+1];
	end
	if (byteenable[2]) begin
	  readdata[23:16] <= data[address+2];
	end
	if (byteenable[3]) begin
	  readdata[31:24] <= data[address+3];
      end
    end
    if (write && ~address[31]) begin
      if (byteenable[0]) begin
        data[address] <= writedata[7:0];
      end
      if (byteenable[1]) begin
        data[address+1] <= writedata[15:8];
      end
      if (byteenable[2]) begin
        data[address+2] <= writedata[23:16];
      end
      if (byteenable[3]) begin
        data[address+3] <= writedata[31:24];
      end
    end

  end

endmodule
