// Implementation of the register file
module regfile (
    input logic clk, reset,
    input logic we3,
    input logic [4:0] ra1, ra2, wa3,
    input logic [31:0] wd3,
    output logic [31:0] rd1, rd2, reg_v0
);

  reg [31:0] rf[31:0];
  //three ported register file
  //read two ports combinationally
  //write third port on rising edge of clock
  //register 0 hardwir3d to 0
  
  integer i;
  
  always @(posedge clk) begin
  	if (reset) begin						//sets all the regs in the regfile to 0 is reset signal is high
  		for (i=0 ; i<32 ; i=i+1) begin
  			rf[i] <= 32'b0;
  		end
  	end
  	else begin 
  		if (we3) rf[wa3] <= wd3;
  	end
  end

  assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
  assign reg_v0 = (~reset) ? rf[2] : reg_v0;		//NOT SURE ABOUT THIS, MIGHT HAVE TO USE AN ALWAYS BLOCK
endmodule




// Implementation of reusable functions used in datapath

module mux2 #(parameter WIDTH = 8) (
    input logic [WIDTH - 1:0] a, b,
    input logic s,
    output logic [WIDTH - 1:0] y
);

  assign y = s ? a : b;
endmodule


module adder (
    input  logic [31:0] a, b,
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

module flipflopr #(parameter WIDTH = 8) (
    input logic clk, reset, clk_enable,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

  always @(negedge reset) begin
  	d <= 8'hBFC00000;
  end
  
  always @(posedge clk, posedge reset) begin
    if (reset) q <= 0;
    else if (clk_enable) q <= d;
  end 
		
endmodule

module signext (
    input  logic [15:0] a,
    output logic [31:0] y
);

  assign y = {{16{a[15]}}, a};
endmodule
