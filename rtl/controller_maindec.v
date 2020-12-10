module maindec (
    input logic [5:0] op,
    funct,
    input logic [4:0] dest,
    output logic memtoreg1,
    data_write,
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


  reg [9:0] controls;


  //Probably needs to use a always@(*)

  assign {regwrite, regdst2, regdst1, alusrc, branch, data_write, memtoreg1, jump, aluop} = controls;
  assign loadcontrol = 3'b101;	//3'b101 is a basic Load Word (Lw) set as default to avoid random signal if not accessed.
  assign memtoreg2 = jump | pcsrc;


  // Assign 11 elements names as aluop consist of 2 bits so rightfully fills the reg controls.
  // Correspond to the bits below from left to right in the same order (starting with regwrite and ending with aluop).


  always @(*)
    case (op)
      6'b000000:
      case (funct)
      	6'b010001: begin  //Move to High MTHI
          controls = 10'b0000000010;
        end
        6'b010100: begin  //Move to Low MTLO
          controls = 10'b0000000010;
        end
        6'b001001: begin  //Jump register and link JALR & link in reg $31
          controls = 10'b1100000101;
          jump1 = 1;					//We set both as J-type to extract value in reg$a aluop: [01]
        end
        6'b001000: begin  //Jump register
          controls = 10'b0000000101;
          jump1 = 1;
        end
        6'b010001: controls = 10'b1000000010;  //Move to high       No need to write enable register?
        6'b010100: controls = 10'b1000000010;  //Move to low		  As HI and LO are reg in ALU module
        default:   controls = 10'b1010000010;  //R-type instruction
      endcase

      6'b100000: begin
        controls = 10'b1001001000;  //Load byte
        loadcontrol = 3'b000;
      end
      6'b100100: begin
        controls = 10'b1001001000;  //Load byte unsigned
        loadcontrol = 3'b001;
      end
      6'b100001: begin
        controls = 10'b1001001000;  //Load halfword
        loadcontrol = 3'b010;
      end
      6'b100101: begin
        controls = 10'b1001001000;  //Load halfword unisigned
        loadcontrol = 3'b011;
      end
      6'b001111: begin
        controls = 10'b1001001000;  //Load upper immidiate
        loadcontrol = 3'b100;
      end
      6'b100011: begin
        controls = 10'b1001001000;  //Load word
        loadcontrol = 3'b101;
      end
      6'b100010: begin
        controls = 10'b1001001000;  //Load word left
        loadcontrol = 3'b110;
      end
      6'b100110: begin
        controls = 10'b1001001000;  //Load word right
        loadcontrol = 3'b111;
      end

      6'b101000: controls = 10'b0001010000;  //Store byte
      6'b101001: controls = 10'b0001010000;  //Store halfword
      6'b101011: controls = 10'b0001010000;  //Store word
      6'b000100: controls = 10'b0000100010;  //Branch on = 0
      6'b000001:
      case (dest)
        5'b00001: controls = 10'b0000100010;  //Branch on >= 0
        5'b10001: controls = 10'b1100100010;  //Branch on >= 0 /link (regwrite active)
        5'b00000: controls = 10'b0000100010;  //Branch on < 0
        5'b10000: controls = 10'b1100100010;  //Branch on < 0 /link
        default:  controls = 10'bxxxxxxxxxx;
      endcase
      6'b000111: controls = 10'b0000100010;  //Branch on > 0
      6'b000110: controls = 10'b0000100010;  //Branch on = 0
      6'b000101: controls = 10'b0000100010;  //Branch on != 0
      6'b001001: controls = 10'b1001000010;  //ADD unsigned immediate
      6'b000010: controls = 10'b0000000101;  //Jump
      6'b000011: controls = 10'b1100000101;  //Jump and link
      6'b001100: controls = 10'b1001000010;  //ANDI
      6'b001101: controls = 10'b1001000010;  //ORI
      6'b001110: controls = 10'b1001000010;  //XORI
      6'b001010: controls = 10'b1001000010;  //Set on less than immediate (signed)
      6'b001011: controls = 10'b1001000010;  //Set on less than immediate unsigned
      default: controls = 10'bxxxxxxxxxx;  //???
    endcase
endmodule


// We are currently setting all the control signals by looking at the opcode of the instrunctions.
// We created an reg (=array) of control signals so that it is easier to implement.
// In order to understand this section please refer to page 376 of the book (table 7.3) for team.

