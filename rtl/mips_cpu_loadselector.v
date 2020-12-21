module loadselector (
    input  logic [31:0] a, b,
    input  logic [ 2:0] controls,
    output logic [31:0] y
);
reg [31:0] c;

  always @(*) begin
  	c = {a[31:2], 2'b0};
    case (controls)
      3'b000: begin  					//Load byte signed
        if (a[7] == 1) begin
          y = {24'hffffff, a[7:0]};
        end else begin
          y = {24'b0, a[7:0]};
        end
      end

      3'b001: begin
        y = {24'b0, a[7:0]};  			//Load byte unsigned
      end

      3'b010: begin  					//Load halfword signed
        if (a[15] == 1) begin
          y = {16'hffff, a[15:0]};
        end else begin
          y = {16'b0, a[15:0]};
        end
      end

      3'b011: y = {16'b0, a[15:0]};  	//Load halfword unsigned

      3'b101: y = a;  					//Load word

      3'b110: begin  					//Load word left
        if ((a % 4) == 0) begin
          y = {c[7:0], b[24:0]};
        end else if ((a % 4) == 1) begin
          y = {c[16:0], b[16:0]};
        end else if ((a % 4) == 2) begin
          y = {c[24:0], b[7:0]};
        end else begin
          y = c[31:0];
        end
      end

      3'b111: begin  					//Load word right
        if ((a % 4) == 0) begin
          y = c[31:0];
        end else if ((a % 4) == 1) begin
          y = {b[31:24], c[31:8]};
        end else if ((a % 4) == 2) begin
          y = {b[31:16], c[31:16]};
        end else begin
          y = {b[31:8], c[31:24]};
        end
      end

      default: y = 32'hXXXXXXXX;
    endcase
  end

endmodule

