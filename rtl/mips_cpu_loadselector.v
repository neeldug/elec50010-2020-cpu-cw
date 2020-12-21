module loadselector (
    input  logic [31:0] a,
    b,
    offset,
    input  logic [ 2:0] controls,
    output logic [31:0] y
);

  always @(*) begin
    case (controls)
      3'b000: begin  //Load byte signed
        if (a[7] == 1) begin
          y = {24'hffffff, a[7:0]};
        end else begin
          y = {24'b0, a[7:0]};
        end
      end

      3'b001: begin
        y = {24'b0, a[7:0]};  //Load byte unsigned
      end

      3'b010: begin  //Load halfword signed
        if (a[15] == 1) begin
          y = {16'hffff, a[15:0]};
        end else begin
          y = {16'b0, a[15:0]};
        end
      end

      3'b011: y = {16'b0, a[15:0]};  //Load halfword unsigned

      3'b101: y = a;  //Load word

      3'b110: begin  //Load word left
        if ((offset % 4) == 0) begin
          y = {a[7:0], b[23:0]};
        end else if ((offset % 4) == 1) begin
          y = {a[15:0], b[15:0]};
        end else if ((offset % 4) == 2) begin
          y = {a[23:0], b[7:0]};
        end else begin
          y = a[31:0];
        end
      end


      3'b111: begin  //Load word right
        if ((offset % 4) == 0) begin
          y = a[31:0];
        end else if ((offset % 4) == 1) begin
          y = {b[31:24], a[31:8]};
        end else if ((offset % 4) == 2) begin
          y = {b[31:16], a[31:16]};
        end else begin
          y = {b[31:8], a[31:24]};
        end
      end

      default: y = 32'hXXXXXXXX;
    endcase
  end

endmodule

