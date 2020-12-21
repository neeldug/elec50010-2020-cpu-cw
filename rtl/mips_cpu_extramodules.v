// Implementation of the register file
module regfile (
    input logic clk,
    reset,
    input logic we3,
    input logic [4:0] ra1,
    ra2,
    wa3,
    input logic [31:0] wd3,
    output logic [31:0] rd1,
    rd2,
    reg_v0
);

  reg [31:0] rf[31:0];
  //three ported register file
  //read two ports combinationally
  //write third port on rising edge of clock
  //register 0 hardwir3d to 0

  integer i;

  always @(posedge clk) begin
    if (reset) begin  //sets all the regs in the regfile to 0 is reset signal is high
      for (i = 0; i < 32; i = i + 1) begin
        rf[i] <= 32'b0;
      end
    end else begin
      if (we3) rf[wa3] <= wd3;
    end
  end

  assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
  assign reg_v0 = rf[2];
endmodule


module register_parallel (
    input logic clk,
    reset,
    input logic we,
    input logic [31:0] wd,
    output logic [31:0] rd
);

  reg [31:0] reg32;

  always @(posedge clk) begin
    if (reset) reg32 <= 0;
    else if (we) reg32 <= wd;
  end

  assign rd = reg32;

endmodule


module delay_slot_register (
    input logic clk,
    reset,
    clk_enable,
    stall,
    input logic [31:0] d,
    output logic [31:0] q
);


  always @(negedge reset) begin
    q <= 32'hBFC00004;
  end

  always_ff @(posedge clk) begin
    if (reset) begin  //sets all the regs in the regfile to 0 is reset signal is high
      q <= 0;
    end else begin
      if (clk_enable & (~stall)) q <= d;
    end
  end
endmodule


module mux2 #(
    parameter WIDTH = 32
) (
    input logic [WIDTH - 1:0] a,
    b,
    input logic s,
    output logic [WIDTH - 1:0] y
);

  assign y = s ? b : a;
endmodule


module adder (
    input  logic [31:0] a,
    b,
    output logic [31:0] y
);

  assign y = a + b;
endmodule


module shiftleft2 (
    input  logic [31:0] a,
    output logic [31:0] y
);

  assign y = {{a[29:0]}, 2'b00};
endmodule


module shiftleft16 (
    input  logic [31:0] a,
    output logic [31:0] y
);

  assign y = {{a[15:0]}, 16'b0};
endmodule


module signext (
    input  logic [15:0] a,
    input  logic selector,
    output logic [31:0] y
);
always @* begin
	if(selector) begin
	  y = {16'b0, a};
	end else begin
	  y = {{16{a[15]}}, a};
	end
end
endmodule


module pc_register (
    input logic clk,
    reset,
    clk_enable,
    stall,
    output logic active,
    input logic [31:0] d,
    output logic [31:0] q
);

  always @(negedge reset) begin
    active = 1'b1;
    q = 32'hBFC00000;
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      q <= 32'b0;
    end else if (clk_enable & (~stall)) begin
      if (d == 32'b0) active <= 0;
      q <= d;
    end
  end

endmodule


module sb_sh_scheduler (
    input logic clk,
    clk_enable,
    reset,
    input logic [31:0] normal_instr_data,
    output logic [31:0] normal_or_scheduled_instr_data,

    output logic stall,
    mux_stage2,
    mux_stage3,
    parallel_path
);

  logic [ 1:0] state;

  logic [ 5:0] opcode;
  logic [ 4:0] s;  //dest in memory of store byte/halfword
  logic [ 4:0] t;  //source register of byte/halfword to load
  logic [15:0] immediate;

  assign opcode = normal_instr_data[31:26];
  assign s = normal_instr_data[25:21];
  assign t = normal_instr_data[20:16];
  assign immediate = normal_instr_data[15:0];

  initial begin
    state = 2'b00;
    stall = 0;
    mux_stage2 = 0;
    mux_stage3 = 0;
    parallel_path = 0;
  end

  always @(negedge clk) begin
    if (opcode == 6'b101000) begin  //Store-byte instruction
      if (state == 2'b00) begin
        stall <= 1;
        parallel_path <= 1;
        normal_or_scheduled_instr_data <= {
          6'b100011, s, 5'b0  /*reg32*/, immediate
        };  //load word in memory location that is the dest of the full instruction into reg32

        state <= 2'b01;
      end else if (state == 2'b01) begin
        mux_stage2 <= 1;
        mux_stage3 <= 0;
        normal_or_scheduled_instr_data <= {
          6'b0, 5'b0  /*reg32*/, t, 5'b0  /*reg32*/, 5'b0, 6'b111111
        };  //alu byte operation

        state <= 2'b10;
      end else if (state == 2'b10) begin
        mux_stage2 <= 0;
        mux_stage3 <= 1;
        normal_or_scheduled_instr_data <= {
          6'b101011, s, 5'b0  /*reg32*/, immediate
        };  //store word in reg32 back into memory location that is the dest of the full instruction

        //unstall PC and delay slot
        stall <= 0;
        state <= 2'b00;
      end
    end else if (opcode == 6'b101001) begin  //Store-halfword instruction
      if (state == 2'b00) begin
        stall <= 1;
        parallel_path <= 1;
        normal_or_scheduled_instr_data <= {6'b100011, s, 5'b0  /*reg32*/, immediate};  //load word

        state <= 2'b01;
      end else if (state == 2'b01) begin
        mux_stage2 <= 1;
        mux_stage3 <= 0;
        normal_or_scheduled_instr_data <= {
          6'b0, 5'b0  /*reg32*/, t, 5'b0  /*reg32*/, 5'b0, 6'b111110
        };  //alu half_word operation

        state <= 2'b10;
      end else if (state == 2'b10) begin
        mux_stage2 <= 0;
        mux_stage3 <= 1;
        normal_or_scheduled_instr_data <= {6'b101011, s, 5'b0  /*reg32*/, immediate};  //store word

        //unstall PC and delay slot
        stall <= 0;
        state <= 2'b00;
      end
    end else begin
      mux_stage2 <= 0;
      mux_stage3 <= 0;
      parallel_path <= 0;
      normal_or_scheduled_instr_data <= normal_instr_data;
    end
  end

endmodule
