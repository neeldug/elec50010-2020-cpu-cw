module alu (
    input logic reset,
    input logic [4:0] control,
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [4:0] shamt,
    output logic zero,
    output logic [31:0] y
);

  logic [31:0] x, x2;
  logic [63:0] r1, r2, z;
  logic [31:0] i;
  reg [31:0] HI, LO;

  always @(*) begin
    if (~reset) begin
      case (control)
        5'b00000: y = a & b;  //AND
        5'b00001: y = a | b;  //OR
        5'b00010: y = a ^ b;  //XOR
        5'b00011: y = a + b;  //ADDU
        5'b00100: begin  //SUBU
          x = (~b + 1);
          y = a + x;
        end
        5'b00101: y = {31'b0, (a < b)};  //SLT Unsigned

        5'b00110: begin  //SLT signed
          if (a[31] != b[31]) begin
            if (a[31] > b[31]) begin
              y = {31'b0, 1'b1};
            end else begin
              y = 32'b0;
            end
          end else begin
            if (a < b) begin
              y = {31'b0, 1'b1};
            end else begin
              y = 32'b0;
            end
          end
        end

        5'b00111: begin  //MULTU Multiplication unsigned
          r1 = {32'b0, a};
          r2 = {32'b0, b};
          z  = r1 * r2;
          HI = z[63:32];
          LO = z[31:0];
        end

        5'b01000: begin  //MULT multiplication signed
          if (a[31] == b[31]) begin
            if ((a[31] == 0) & (b[31] == 0)) begin
              r1 = {32'b0, a};
              r2 = {32'b0, b};
              z  = r1 * r2;
              HI = z[63:32];
              LO = z[31:0];
            end else begin
              x  = ~a + 1;
              x2 = ~b + 1;
              r1 = {32'b0, x};
              r2 = {32'b0, x2};
              z  = r1 * r2;
              HI = z[63:32];
              LO = z[31:0];
            end
          end else begin
            if ((a[31] == 0) & (b[31] == 1)) begin
              x2 = ~b + 1;
              r1 = {32'b0, a};
              r2 = {32'b0, x2};
              z  = ~(r1 * r2) + 1;
              HI = z[63:32];
              LO = z[31:0];
            end else begin
              x  = ~a + 1;
              r1 = {32'b0, x};
              r2 = {32'b0, b};
              z  = ~(r1 * r2) + 1;
              HI = z[63:32];
              LO = z[31:0];
            end
          end
        end


        5'b01001: y = b << shamt;  //shift left logical
        // we take the shift variable from instr[10:6] included in the Immediate field

        5'b01010: y = b << a;  //shift left logical variable

        5'b01011: y = b >>> shamt;  //shift right arithmetic

        5'b01100: y = b >> shamt;  //shift right logical

        5'b01101: y = b >>> a;  //shift right arithmetic variable

        5'b01110: y = b >> a;  //shift right logical variable

        5'b01111: begin  //Divid: DIV
          if (a[31] == b[31]) begin
            if ((a[31] == 0) & (b[31] == 0)) begin
              HI = a % b;
              LO = a / b;
            end else begin
              x  = ~a + 1;
              x2 = ~b + 1;
              HI = -(x % x2);
              LO = x / x2;
            end
          end else begin
            if ((a[31] == 0) & (b[31] == 1)) begin
              x2 = ~b + 1;
              HI = a % x2;
              LO = -(a / x2);
            end else begin
              x  = ~a + 1;
              HI = -(x % b);
              LO = -(x / b);
            end
          end
        end

        5'b10000: begin  //Divid unsigned: DIVU
          HI = a % b;
          LO = a / b;
        end


        5'b10001: HI = a;  //MTHI: move to High

        5'b10010: LO = a;  //MTLO: move to Low


        5'b10011: begin  //Branch on < 0 and Branch on < 0 / link
          if (a[31] == 1) begin
            y = 32'b0;
          end else y = {31'b0, 1'b1};
        end

        5'b10100: begin  //Branch on > 0  
          if (a[31] == 0 & a != 32'b0) begin
            y = 32'b0;
          end else y = {31'b0, 1'b1};
        end

        5'b10101: begin  //Branch on >= 0 (link or not)  
          if (a[31] == 0) begin
            y = 32'b0;
          end else y = {31'b0, 1'b1};
        end

        5'b10110: begin  //Branch on a != b   
          if (a != b) begin
            y = 32'b0;
          end else y = {31'b0, 1'b1};
        end

        5'b10111: begin  //Branch on <=0
          if (a[31] == 1 | a == 32'b0) begin
            y = 32'b0;
          end else y = {31'b0, 1'b1};
        end

        5'b11000: y = a;  //Jump register JR/JALR

        5'b11001: y = {b[15:0], 16'b0};  //Load upper Immidiate

        5'b11010: y = HI;  //MFHI

        5'b11011: y = LO;  //MFLO
      
      	5'b11100: y = {a[31:8], b[7:0]}; // Store byte: SB
      
      	5'b11101: y = {a[31:16], b[15:0]}; // Store halfword: SH

        default:  y = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;  //???	 
      endcase

    end else begin  //If reset signal is asserted, then sets both registers HI and LO to zero
      HI = 0;
      LO = 0;
    end

  end

  // Zero flag is determined from the result of the ALU
  always @(y) begin
    if (y == 32'b0) begin
      zero = 1;
    end else begin
      zero = 0;
    end
  end

endmodule
