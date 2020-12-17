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
    reg_v0	//, reg_v3			//DEBUGGING
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
  assign reg_v0 = (~reset) ? rf[2] : 0;
  //assign reg_v3 = (~reset) ? rf[3] : reg_v3;		//DEBUGGING
endmodule

module regfile2 #(
    parameter WIDTH = 31
) (
    input logic clk,
    reset,
    input logic we,
    input logic [WIDTH:0] d,
    output logic [WIDTH:0] q
);
  reg i;

  always_ff @(posedge clk) begin
    if (reset) begin  //sets all the regs in the regfile to 0 is reset signal is high
      q <= 0;
      i <= 1;
    end else begin
      if (we) begin
        q <= i ? 0 : d;
        i <= 0;
      end
    end
  end
endmodule


module regfile1 #(
    parameter WIDTH = 31
) (
    input logic clk,
    reset,
    input logic we,
    input logic [WIDTH:0] d,
    output logic [WIDTH:0] q
);

  always_ff @(posedge clk) begin
    if (reset) begin  //sets all the regs in the regfile to 0 is reset signal is high
      q <= 0;
    end else begin
      if (we) q <= d;
    end
  end
endmodule

// Implementation of reusable functions used in datapath

module mux2 #(
    parameter WIDTH = 8
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

module flipflopr #(
    parameter WIDTH = 32
) (
    input logic clk,
    reset,
    clk_enable,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
  reg x;

  initial x = 1'b0;
  always @(negedge reset) begin
    x = 1'b1;
  end

  always_ff @(posedge clk) begin
    if (reset) q <= x ? 32'hBFC00000 : 32'b0;
    else if (clk_enable) begin
      q <= x ? 32'hBFC00000 : d;
      x <= 0;
    end
  end

endmodule

module signext (
    input  logic [15:0] a,
    output logic [31:0] y
);

  assign y = {{16{a[15]}}, a};
endmodule


module endian_switch (
    input  logic [31:0] in,
    output logic [31:0] out
);

  assign out = {in[7:0], in[15:8], in[23:16], in[31:24]};

endmodule
