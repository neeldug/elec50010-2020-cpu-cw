module maindec (
	input logic clk,
    input logic [5:0] op,
    funct,
    input logic [4:0] dest,
    output logic storeloop,
    output logic memtoreg1,
    data_write,
    data_read,
    output logic branch,
    alusrc,
    output logic regdst2,
    regdst1,
    output logic regwrite,
    output logic jump1,
    jump,
    output logic [1:0] aluop,
    output logic [2:0] loadcontrol
);

  reg [1:0] x;
  reg [11:0] controls;
initial begin
	x = 0;
end


//  assign {regwrite, regdst2, regdst1, alusrc, branch, data_read, data_write, memtoreg1, jump1, jump, aluop} = controls;
  assign regwrite = controls[11];
  assign regdst2 = controls[10];
  assign regdst1 = controls[9];
  assign alusrc = controls[8];
  assign branch = controls[7];
  assign data_read = controls[6];
  assign data_write = controls[5];
  assign memtoreg1 = controls[4];
  assign jump1 = controls[3];
  assign jump = controls[2];
  assign aluop = controls[1:0];

  // Assign 11 elements names as aluop consist of 2 bits so rightfully fills the reg controls.
  // Correspond to the bits below from left to right in the same order (starting with regwrite and ending with aluop).


  always @(*)
    case (op)
      6'b000000:
      case (funct)
        //No need to write enable register as HI and LO are reg in ALU module.
        6'b010001: begin  //Move to High MTHI
          controls = 12'b000000000010;
        end
        6'b010100: begin  //Move to Low MTLO
          controls = 12'b000000000010;
        end
        6'b001001: begin  //Jump register and link JALR & link in reg $31
          controls = 12'b110010001101;
         // jump1 = 1;					//We set both as J-type to extract value in reg$a aluop: [01]
        end
        6'b001000: begin  //Jump register
          controls = 12'b000010001101;
         // jump1 = 1;
        end
        default: controls = 12'b101000000010;  //R-type instructions 
      endcase

      6'b100000: begin        	
        controls = 12'b100101010000;  //Load byte
        loadcontrol = 3'b000;
      end
      6'b100100: begin
        controls = 12'b100101010000;  //Load byte unsigned
        loadcontrol = 3'b001;
      end
      6'b100001: begin
        controls = 12'b100101110000;  //Load halfword
        loadcontrol = 3'b010;
      end
      6'b100101: begin
        controls = 12'b100101010000;  //Load halfword unisigned
        loadcontrol = 3'b011;
      end
      6'b001111: begin
        controls = 12'b100101000010;  //Load upper immidiate
      end
      6'b100011: begin
        controls = 12'b100101010000;  //Load word
        loadcontrol = 3'b101;
      end
      6'b100010: begin
        controls = 12'b100101010000;  //Load word left
        loadcontrol = 3'b110;
      end
      6'b100110: begin
        controls = 12'b100101010000;  //Load word right
        loadcontrol = 3'b111;
      end

      6'b101000: begin
/*      	always @(posedge clk) begin
      	 if(x == 2'b00) begin
        	storeloop <= 1;
        	controls <= 12'b111101010000;  //Load word into reg$30
        	loadcontrol <= 3'b101;
        	x <= 2'b01;
        	end
        if(x==2'b01) begin
        	storeloop1 <= 1;
        	controls <= 12'b100000000010;  // do in alu $t= {$30[31:8], $t[7:0]}
        	x <= 2'b10;
        	end
        if(x==2'b10) begin
        	storeloop1 <= 0;
        	controls <= 12'b000100100000;  //Store byte
        	x <= 2'b11;
        	end
        if(x==2'b11) begin
        	storeloop <= 0;
        	end		*/
        end
      6'b101001: controls = 12'b000100100000;  //Store halfword
      6'b101011: controls = 12'b000100100000;  //Store word
      6'b000100: controls = 12'b000010000010;  //Branch on = 0
      6'b000001:
      case (dest)
        5'b00001: controls = 12'b000010000010;  //Branch on >= 0
        5'b10001: controls = 12'b110010000010;  //Branch on >= 0 /link (regwrite active)
        5'b00000: controls = 12'b000010000010;  //Branch on < 0
        5'b10000: controls = 12'b110010000010;  //Branch on < 0 /link
        default:  controls = 12'bxxxxxxxxxxxx;
      endcase
      6'b000111: controls = 12'b000010000010;  //Branch on > 0
      6'b000110: controls = 12'b000010000010;  //Branch on = 0
      6'b000101: controls = 12'b000010000010;  //Branch on != 0
      6'b001001: controls = 12'b100100000010;  //ADD unsigned immediate
      6'b000010: controls = 12'b000010000101;  //Jump
      6'b000011: controls = 12'b110010000101;  //Jump and link
      6'b001100: controls = 12'b100100000010;  //ANDI
      6'b001101: controls = 12'b100100000010;  //ORI
      6'b001110: controls = 12'b100100000010;  //XORI
      6'b001010: controls = 12'b100100000010;  //Set on less than immediate (signed)
      6'b001011: controls = 12'b100100000010;  //Set on less than immediate unsigned
      default: controls = 12'bxxxxxxxxxxxx;  //???
    endcase
endmodule


// We are currently setting all the control signals by looking at the opcode of the instructions.
// We created an reg (=array) of control signals so that it is easier to implement.
// In order to understand this section please refer to page 376 of the book (table 7.3) for team.

