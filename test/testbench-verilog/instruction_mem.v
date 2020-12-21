module instruction_mem (
    input  logic [31:0] instr_address,  // = OFFSET + PC*4
    output logic [31:0] instr
);

  parameter INSTR_INIT_FILE = "";
  localparam START = 32'hBFC00000;
  reg [7:0] imem[START:START+511];

  //initialization
  initial begin
    integer i;
    for (i = START; i < START + 511; i++) begin
      imem[i] = 0;
    end

    if (INSTR_INIT_FILE != "") begin
      $readmemh(INSTR_INIT_FILE, imem);
    end
  end

  //making the async read
  always_comb begin
    instr = {
      imem[instr_address+3], imem[instr_address+2], imem[instr_address+1], imem[instr_address]
    };
  end
endmodule
